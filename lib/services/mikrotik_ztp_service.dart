import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'mikrotik_ztp_web_stub.dart'
    if (dart.library.html) 'mikrotik_ztp_web_helper.dart' as web_helper;

class MikrotikDeviceInfo {
  final String gatewayIp;
  final String boardName;
  final String model;
  final String version;
  final String identity;
  final bool isRestSupported;
  final bool isAuthRequired;

  MikrotikDeviceInfo({
    required this.gatewayIp,
    required this.boardName,
    required this.model,
    required this.version,
    required this.identity,
    required this.isRestSupported,
    this.isAuthRequired = false,
  });
}

class MikrotikZtpService {
  final Dio _centralApiDio;

  MikrotikZtpService({required Dio dio}) : _centralApiDio = dio;

  /// 1. Fetch ZTP payload from central Tiknet API
  Future<Map<String, dynamic>> fetchZtpPayload(int routerId) async {
    try {
      final response = await _centralApiDio.get(
        '/routers/$routerId/ztp-payload/',
      );

      if (response.data != null && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data']);
      } else if (response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Format de réponse invalide');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [MikrotikZtpService] Error fetching ZTP payload: $e');
      }
      rethrow;
    }
  }

  /// 2. Probe local gateway IP to test RouterOS REST API availability
  Future<MikrotikDeviceInfo> probeLocalGateway({
    String gatewayIp = '192.168.88.1',
    String username = 'admin',
    String password = '',
  }) async {
    final localDio = Dio(
      BaseOptions(
        baseUrl: 'http://$gatewayIp',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'application/json',
        },
      ),
    );

    try {
      final identityResp = await localDio.get('/rest/system/identity');
      String identity = 'MikroTik';
      if (identityResp.data is List && identityResp.data.isNotEmpty) {
        identity = identityResp.data[0]['name'] ?? 'MikroTik';
      } else if (identityResp.data is Map) {
        identity = identityResp.data['name'] ?? 'MikroTik';
      }

      final resourceResp = await localDio.get('/rest/system/resource');
      String boardName = 'MikroTik Router';
      String model = 'Board';
      String version = 'v7.x';

      if (resourceResp.data is List && resourceResp.data.isNotEmpty) {
        final res = resourceResp.data[0];
        boardName = res['board-name'] ?? res['platform'] ?? 'MikroTik';
        model = res['board-name'] ?? res['architecture-name'] ?? 'RouterBoard';
        version = res['version'] ?? '7.x';
      } else if (resourceResp.data is Map) {
        final res = resourceResp.data;
        boardName = res['board-name'] ?? res['platform'] ?? 'MikroTik';
        model = res['board-name'] ?? res['architecture-name'] ?? 'RouterBoard';
        version = res['version'] ?? '7.x';
      }

      return MikrotikDeviceInfo(
        gatewayIp: gatewayIp,
        boardName: boardName,
        model: model,
        version: version,
        identity: identity,
        isRestSupported: true,
        isAuthRequired: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [MikrotikZtpService] REST API probe failed on $gatewayIp: $e');
      }

      if (e is DioException && (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
        return MikrotikDeviceInfo(
          gatewayIp: gatewayIp,
          boardName: 'MikroTik Router',
          model: 'Mot de passe requis',
          version: 'v7.x',
          identity: 'Verrouillé',
          isRestSupported: true,
          isAuthRequired: true,
        );
      }

      return MikrotikDeviceInfo(
        gatewayIp: gatewayIp,
        boardName: 'Inconnu',
        model: 'MikroTik',
        version: 'Inconnu',
        identity: 'Inconnu',
        isRestSupported: false,
        isAuthRequired: false,
      );
    }
  }

  /// Validate admin credentials against router REST API
  Future<bool> validateRouterCredentials({
    String gatewayIp = '192.168.88.1',
    required String username,
    required String password,
  }) async {
    final localDio = Dio(
      BaseOptions(
        baseUrl: 'http://$gatewayIp',
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'application/json',
        },
      ),
    );

    try {
      final resp = await localDio.get('/rest/system/identity');
      return resp.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔒 [MikrotikZtpService] Credential validation failed for $username: $e');
      }
      return false;
    }
  }

  /// Candidate local gateway IPs across common ISP and private subnet ranges
  static const List<String> candidateGateways = [
    '192.168.88.1',  // MikroTik default out-of-the-box
    '192.168.1.1',   // Standard ISP LAN / Router
    '192.168.0.1',   // Standard ISP LAN
    '10.0.0.1',      // Enterprise / Private LAN
    '192.168.10.1',  // Custom subnet
    '192.168.2.1',   // Custom subnet
    '172.16.0.1',    // Class B subnet
  ];

  /// Smart Multi-Subnet & Platform Discovery: Probes candidate gateways & platform connected routers
  Future<MikrotikDeviceInfo> discoverLocalGateway({
    String username = 'admin',
    String password = '',
    String? preferredIp,
    List<Map<String, dynamic>>? registeredPlatformRouters,
  }) async {
    final List<String> ipsToScan = [];
    if (preferredIp != null && preferredIp.trim().isNotEmpty) {
      ipsToScan.add(preferredIp.trim());
    }

    for (final ip in candidateGateways) {
      if (!ipsToScan.contains(ip)) {
        ipsToScan.add(ip);
      }
    }

    // Also include IP addresses of routers registered to the user's platform account
    if (registeredPlatformRouters != null) {
      for (final r in registeredPlatformRouters) {
        final ip = r['ip_address']?.toString() ?? r['wg_ip']?.toString();
        if (ip != null && ip.trim().isNotEmpty && !ipsToScan.contains(ip.trim())) {
          ipsToScan.add(ip.trim());
        }
      }
    }

    if (kDebugMode) {
      debugPrint('🔍 [MikrotikZtpService] Scanning candidate gateways & platform IPs: $ipsToScan');
    }

    // Run probes in parallel across all candidate subnets
    final List<Future<MikrotikDeviceInfo>> probeTasks = ipsToScan.map((ip) {
      return probeLocalGateway(
        gatewayIp: ip,
        username: username,
        password: password,
      );
    }).toList();

    final results = await Future.wait(probeTasks);

    // 1. Return unauthenticated responsive MikroTik device first
    for (final info in results) {
      if (info.isRestSupported && !info.isAuthRequired) {
        if (kDebugMode) {
          debugPrint('✅ [MikrotikZtpService] Found out-of-box MikroTik at ${info.gatewayIp}');
        }
        return info;
      }
    }

    // 2. Return password-protected responsive MikroTik device
    for (final info in results) {
      if (info.isRestSupported && info.isAuthRequired) {
        if (kDebugMode) {
          debugPrint('🔒 [MikrotikZtpService] Found password-protected MikroTik at ${info.gatewayIp}');
        }
        return info;
      }
    }

    // 3. Smart Platform Fallback: If local HTTP probe is blocked by HTTPS browser CORS, but user has registered routers on platform
    if (registeredPlatformRouters != null && registeredPlatformRouters.isNotEmpty) {
      final activeRouter = registeredPlatformRouters.firstWhere(
        (r) => r['is_active'] == true || r['status'] == 'online',
        orElse: () => registeredPlatformRouters.first,
      );
      final rName = activeRouter['name']?.toString() ?? 'MikroTik Router';
      final rIp = activeRouter['ip_address']?.toString() ?? activeRouter['wg_ip']?.toString() ?? '10.0.0.X';
      final rModel = activeRouter['slug']?.toString() ?? 'Routeur Plateforme';

      if (kDebugMode) {
        debugPrint('🌐 [MikrotikZtpService] Found online platform router: $rName ($rIp)');
      }

      return MikrotikDeviceInfo(
        gatewayIp: rIp,
        boardName: rName,
        model: 'MikroTik ($rModel)',
        version: 'v7.x',
        identity: rName,
        isRestSupported: true,
        isAuthRequired: password.isEmpty, // Prompt for admin sticker password if empty
      );
    }

    // 4. Default fallback
    return results.isNotEmpty ? results[0] : MikrotikDeviceInfo(
      gatewayIp: preferredIp ?? '192.168.88.1',
      boardName: 'Inconnu',
      model: 'MikroTik',
      version: 'Inconnu',
      identity: 'Inconnu',
      isRestSupported: false,
      isAuthRequired: false,
    );
  }

  /// 3. Execute ZTP Provisioning steps directly over RouterOS REST API
  Future<bool> executeZtpProvisioning({
    required String gatewayIp,
    required Map<String, dynamic> ztpPayload,
    required Function(String status, double progress) onProgress,
    String defaultAdminUsername = 'admin',
    String defaultAdminPassword = '',
  }) async {
    final restSteps = ztpPayload['rest_steps'] as List<dynamic>? ?? [];
    final int totalSteps = restSteps.length + 2; // Payload steps + registration + full config fetch
    int completedSteps = 0;

    final String adminPassword = ztpPayload['admin_password'] ?? '';
    final String registerUrl = ztpPayload['register_url'] ?? '';
    final String bootstrapToken = ztpPayload['bootstrap_token'] ?? '';

    if (kIsWeb) {
      onProgress('⚡ Provisionnement Web Automatique en cours...', 0.50);
      final token = ztpPayload['bootstrap_token']?.toString() ?? '';
      final rName = ztpPayload['router_name']?.toString() ?? 'MikroTik';
      await web_helper.executeWebZtpFormProvisioning(
        gatewayIp: gatewayIp,
        bootstrapToken: token,
        routerName: rName,
        username: defaultAdminUsername,
        password: defaultAdminPassword,
      );
      onProgress('✅ Provisionnement Web transmis ! Vérification du tunnel VPN...', 0.75);
      return true;
    }

    Dio restDio = Dio(
      BaseOptions(
        baseUrl: 'http://$gatewayIp',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$defaultAdminUsername:$defaultAdminPassword'))}',
          'Content-Type': 'application/json',
        },
      ),
    );

    for (final step in restSteps) {
      final stepMap = Map<String, dynamic>.from(step);
      final String action = stepMap['action'] ?? '';
      final String method = (stepMap['method'] ?? 'PUT').toUpperCase();
      final String path = stepMap['path'] ?? '';
      final Map<String, dynamic> payload = Map<String, dynamic>.from(stepMap['payload'] ?? {});

      completedSteps++;
      final double progress = completedSteps / totalSteps;

      onProgress(_getFriendlyStepName(action), progress);
      if (kDebugMode) {
        debugPrint('⚙️ [MikrotikZtpService] Step $completedSteps/$totalSteps: $action ($method $path)');
      }

      try {
        if (method == 'PUT') {
          await restDio.put(path, data: payload);
        } else if (method == 'POST') {
          await restDio.post(path, data: payload);
        } else if (method == 'PATCH') {
          await restDio.patch(path, data: payload);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [MikrotikZtpService] Step $action warning/error: $e. Retrying or continuing...');
        }
        if (action == 'setup_admin_user') {
          restDio.options.headers['Authorization'] =
              'Basic ${base64Encode(utf8.encode('tiknet-admin:$adminPassword'))}';
        }
      }

      if (action == 'setup_admin_user') {
        restDio.options.headers['Authorization'] =
            'Basic ${base64Encode(utf8.encode('tiknet-admin:$adminPassword'))}';
      }

      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Step: Trigger backend registration
    completedSteps++;
    onProgress('Enregistrement du routeur auprès du contrôleur central...', completedSteps / totalSteps);
    if (registerUrl.isNotEmpty && bootstrapToken.isNotEmpty) {
      try {
        await _centralApiDio.post(
          registerUrl,
          options: Options(
            headers: {
              'X-TIKNET-TOKEN': bootstrapToken,
            },
          ),
        );
        if (kDebugMode) {
          debugPrint('✅ [MikrotikZtpService] Router registered successfully at central API');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [MikrotikZtpService] Registration notification warning: $e');
        }
      }
    }

    // Final Step Complete
    onProgress('Configuration ZTP terminée avec succès !', 1.0);
    return true;
  }

  String _getFriendlyStepName(String action) {
    switch (action) {
      case 'setup_admin_user':
        return 'Sécurisation du compte administrateur (tiknet-admin)...';
      case 'create_wg_primary':
      case 'create_wg_backup':
        return 'Création des interfaces VPN WireGuard...';
      case 'assign_wg_ip_primary':
      case 'assign_wg_ip_backup':
        return 'Attribution de l\'IP de management sécurisée...';
      case 'add_wg_peer_primary':
      case 'add_wg_peer_backup':
        return 'Connexion des tunnels VPN avec le VPS central...';
      case 'add_route_primary':
      case 'add_route_backup':
        return 'Configuration des routes statiques sécurisées...';
      case 'fetch_bootstrap_script':
        return 'Téléchargement et exécution de la configuration finale...';
      default:
        return 'Application de la configuration MikroTik...';
    }
  }

  /// 4. Reverse Verification: Ask backend to ping router via WireGuard VPN
  Future<Map<String, dynamic>> verifyCloudConnection(int routerId) async {
    try {
      final response = await _centralApiDio.get(
        '/routers/$routerId/check-connection/',
      );

      if (response.data != null && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data']);
      } else if (response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'is_connected': false, 'message': 'Réponse vide du backend'};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [MikrotikZtpService] Reverse verification error: $e');
      }
      return {'is_connected': false, 'message': e.toString()};
    }
  }
}
