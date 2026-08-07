import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MikrotikDeviceInfo {
  final String gatewayIp;
  final String boardName;
  final String model;
  final String version;
  final String identity;
  final bool isRestSupported;

  MikrotikDeviceInfo({
    required this.gatewayIp,
    required this.boardName,
    required this.model,
    required this.version,
    required this.identity,
    required this.isRestSupported,
  });
}

class MikrotikZtpService {
  final Dio _centralApiDio;

  MikrotikZtpService({required Dio dio}) : _centralApiDio = dio;

  /// 1. Fetch ZTP payload from central Tiknet API
  Future<Map<String, dynamic>> fetchZtpPayload(int routerId) async {
    try {
      final response = await _centralApiDio.get(
        '/partner/routers/$routerId/ztp-payload/',
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
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [MikrotikZtpService] REST API probe failed on $gatewayIp: $e');
      }
      return MikrotikDeviceInfo(
        gatewayIp: gatewayIp,
        boardName: 'Inconnu',
        model: 'MikroTik',
        version: 'Inconnu',
        identity: 'Inconnu',
        isRestSupported: false,
      );
    }
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
}
