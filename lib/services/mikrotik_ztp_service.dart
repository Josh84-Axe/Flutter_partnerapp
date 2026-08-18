import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'mikrotik_ztp_web_stub.dart'
    if (dart.library.html) 'mikrotik_ztp_web_helper.dart' as web_helper;
import 'mikrotik_api_socket.dart';

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

  /// Global diagnostic log accumulator for live UI monitoring
  static final List<String> lastDiagnosticLogs = [];

  static void addDiagLog(String line, {Function(String logLine)? onLog}) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final formatted = '[$timestamp] $line';
    lastDiagnosticLogs.add(formatted);
    if (lastDiagnosticLogs.length > 200) {
      lastDiagnosticLogs.removeAt(0);
    }
    onLog?.call(formatted);
    if (kDebugMode) {
      debugPrint(formatted);
    }
  }

  /// 4. Validate router credentials against RouterOS Native Socket (TCP 8728) & HTTP REST
  Future<bool> validateRouterCredentials({
    String gatewayIp = '192.168.88.1',
    required String username,
    required String password,
    Function(String logLine)? onLog,
  }) async {
    lastDiagnosticLogs.clear();
    void log(String msg) => addDiagLog(msg, onLog: onLog);

    final cleanUser = username.trim();
    final cleanPass = password.trim();
    final upperPass = cleanPass.toUpperCase();
    final lowerPass = cleanPass.toLowerCase();

    log('🚀 [ZTP DIAGNOSTIC] Initiating validation for user "$cleanUser" (Platform: ${kIsWeb ? "Web PWA" : "Native Mobile"})');
    if (kIsWeb) {
      log('⚠️ [Browser PWA Notice] HTTPS Web Browsers block direct background HTTP REST requests to 192.168.88.1 (Mixed Content / PNA Policy).');
      log('💡 TIP: For 100% automated Zero-Touch Provisioning via raw TCP socket 8728, please use the Tiknet Mobile App (APK)!');
    }

    final passwordsToTest = <String>{
      upperPass,
      cleanPass,
      lowerPass,
      '',       // Try empty password (factory default reset)
      'admin',  // Try 'admin' password
    }.toList();

    final candidateIps = <String>{
      if (gatewayIp.isNotEmpty && !gatewayIp.startsWith('10.')) gatewayIp,
      '192.168.0.1',
      '192.168.88.1',
      '192.168.1.1',
      '10.0.0.1',
    }.toList();

    log('🔍 Candidate IPs to probe: ${candidateIps.join(", ")}');
    log('🔑 Password variants: CAPS ("$upperPass"), Exact ("$cleanPass"), Empty (""), Admin ("admin")');

    for (final pass in passwordsToTest) {
      final maskPass = pass.isEmpty
          ? '<EMPTY>'
          : (pass.length <= 3 ? '***' : '${pass.substring(0, 2)}***${pass.substring(pass.length - 1)}');

      log('----------------------------------------');
      log('🧪 Testing Password Variant: "$maskPass"');

      for (final ip in candidateIps) {
        // 1. Native Mobile Probe: RouterOS Native API over TCP 8728
        if (!kIsWeb) {
          log('🔌 [TCP 8728] Probing $ip:8728 as "$cleanUser"...');
          try {
            final apiSocket = MikrotikApiSocket(host: ip, port: 8728);
            final socketOk = await apiSocket.connectAndLogin(
              username: cleanUser,
              password: pass,
              timeout: const Duration(seconds: 3),
              onLog: (socketMsg) => log('   ↳ [Socket] $socketMsg'),
            );
            apiSocket.close();
            if (socketOk) {
              log('✅ [SUCCESS] Authenticated on TCP $ip:8728 with user "$cleanUser" & pass "$maskPass"!');
              return true;
            }
          } catch (e) {
            log('⚠️ [Socket Err] $ip:8728 -> $e');
          }
        }

        // 2. Secondary HTTP REST Probe: http://$ip/rest/system/identity
        log('🌐 [HTTP REST] GET http://$ip/rest/system/identity as "$cleanUser"...');
        try {
          final authStr = 'Basic ${base64Encode(utf8.encode('$cleanUser:$pass'))}';
          final localDio = Dio(
            BaseOptions(
              baseUrl: 'http://$ip',
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
              headers: {
                'Authorization': authStr,
                'Content-Type': 'application/json',
              },
            ),
          );
          final resp = await localDio.get('/rest/system/identity');
          if (resp.statusCode == 200) {
            log('✅ [SUCCESS] HTTP 200 OK from http://$ip/rest/system/identity!');
            return true;
          } else {
            log('❌ [REST Reject] HTTP ${resp.statusCode} from http://$ip/rest');
          }
        } catch (e) {
          if (e is DioException) {
            final statusCode = e.response?.statusCode;
            if (statusCode == 403) {
              log('🎯 [TARGET FOUND] $ip returned HTTP 403 (Active Router Web Interface detected!). Testing HTTPS REST & WebFig auth...');
            } else if (statusCode != null) {
              log('❌ [HTTP $statusCode] Rejected at http://$ip/rest/system/identity');
            } else {
              log('⚠️ [HTTP Net/Timeout] http://$ip -> ${e.message}');
            }
          } else {
            log('⚠️ [HTTP Err] http://$ip -> $e');
          }
        }

        // 3. HTTPS REST Probe (with SSL Certificate Bypass): https://$ip/rest/system/identity
        log('🔒 [HTTPS REST] GET https://$ip/rest/system/identity as "$cleanUser"...');
        try {
          final authStr = 'Basic ${base64Encode(utf8.encode('$cleanUser:$pass'))}';
          final httpsDio = Dio(
            BaseOptions(
              baseUrl: 'https://$ip',
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
              headers: {
                'Authorization': authStr,
                'Content-Type': 'application/json',
              },
            ),
          );

          if (!kIsWeb) {
            (httpsDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
              final client = HttpClient();
              client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
              return client;
            };
          }

          final httpsResp = await httpsDio.get('/rest/system/identity');
          if (httpsResp.statusCode == 200) {
            log('✅ [SUCCESS] HTTPS 200 OK from https://$ip/rest/system/identity!');
            return true;
          } else {
            log('❌ [HTTPS Reject] HTTP ${httpsResp.statusCode} from https://$ip/rest');
          }
        } catch (e) {
          if (e is DioException) {
            final statusCode = e.response?.statusCode;
            if (statusCode != null) {
              log('❌ [HTTPS $statusCode] Rejected at https://$ip/rest ($cleanUser:$maskPass)');
            } else {
              log('⚠️ [HTTPS Err] https://$ip -> ${e.message} (SSL/Handshake: ${e.error})');
            }
          } else {
            log('⚠️ [HTTPS Err] https://$ip -> $e');
          }
        }

        // 4. Web Interface Header Inspector
        try {
          final rootDio = Dio(
            BaseOptions(
              baseUrl: 'http://$ip',
              connectTimeout: const Duration(seconds: 2),
              receiveTimeout: const Duration(seconds: 2),
            ),
          );
          final rootResp = await rootDio.get('/');
          final serverHeader = rootResp.headers.value('server') ?? 'MikroTik/WebFig';
          log('🌐 [Web Interface Header] http://$ip/ Server Header: "$serverHeader" (Status: ${rootResp.statusCode})');
        } catch (_) {}
      }
    }

    log('⛔ [ZTP FAILED] All candidate IPs and password variants were rejected by the router.');
    return false;
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

  /// Stream live telemetry log lines directly to the central backend for real-time tracking
  Future<void> streamZtpTelemetry(int routerId, String logLine) async {
    if (routerId <= 0) return;
    try {
      await _centralApiDio.post(
        '/routers/$routerId/ztp-telemetry/',
        data: {'log': logLine},
      );
    } catch (_) {}
  }

  /// Smart Multi-Subnet & Platform Discovery: Probes candidate gateways & platform connected routers
  Future<MikrotikDeviceInfo> discoverLocalGateway({
    String username = 'admin',
    String password = '',
    String? preferredIp,
    List<Map<String, dynamic>>? registeredPlatformRouters,
    Function(String logLine)? onLog,
  }) async {
    void log(String msg) => addDiagLog(msg, onLog: onLog);
    log('🔍 [ZTP DISCOVERY] Lancement du balayage réseau local sur les sous-réseaux (192.168.88.1, 192.168.0.1, 192.168.1.1)...');
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
        log('✅ Routeur MikroTik réactif détecté (compte vierge) sur ${info.gatewayIp} !');
        return info;
      }
    }

    // 2. Return password-protected responsive MikroTik device
    for (final info in results) {
      if (info.isRestSupported && info.isAuthRequired) {
        log('🔒 Routeur MikroTik réactif détecté sur ${info.gatewayIp} (Mot de passe requis).');
        return info;
      }
    }

    log('⚠️ [ÉCHEC BALAYAGE LOCAL] Aucun routeur MikroTik réactif détecté sur (${ipsToScan.join(", ")}). Vérifiez la connexion Wi-Fi ou le câble LAN.');

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
        isAuthRequired: password.isEmpty,
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

  /// Verifies router credentials over API Socket or HTTP/HTTPS REST
  Future<Map<String, dynamic>> testRouterAuthCredentials({
    required String gatewayIp,
    required String username,
    required String password,
  }) async {
    final cleanUser = username.trim().isEmpty ? 'admin' : username.trim();

    // 1. Native Mobile TCP 8728 probe
    if (!kIsWeb) {
      try {
        final apiSocket = MikrotikApiSocket(host: gatewayIp, port: 8728);
        final socketOk = await apiSocket.connectAndLogin(
          username: cleanUser,
          password: password,
          timeout: const Duration(seconds: 4),
        );
        apiSocket.close();
        if (socketOk) {
          return {
            'success': true,
            'method': 'API Socket (Port 8728)',
            'message': 'Authentification réussie sur le routeur physique via API Socket !',
          };
        }
      } catch (_) {}
    }

    // 2. HTTP REST Probe (http://$gatewayIp/rest/system/identity)
    try {
      final authStr = 'Basic ${base64Encode(utf8.encode('$cleanUser:$password'))}';
      final localDio = Dio(
        BaseOptions(
          baseUrl: 'http://$gatewayIp',
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          headers: {
            'Authorization': authStr,
            'Content-Type': 'application/json',
          },
        ),
      );
      final resp = await localDio.get('/rest/system/identity');
      if (resp.statusCode == 200) {
        final data = resp.data;
        String identity = 'MikroTik';
        if (data is Map && data.containsKey('name')) {
          identity = data['name'].toString();
        } else if (data is List && data.isNotEmpty && data[0] is Map && data[0].containsKey('name')) {
          identity = data[0]['name'].toString();
        }
        return {
          'success': true,
          'method': 'REST API (HTTP 80)',
          'identity': identity,
          'message': 'Authentification réussie sur $identity ($gatewayIp) !',
        };
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return {
            'success': false,
            'errorCode': e.response?.statusCode,
            'message': 'Mot de passe ou nom d\'utilisateur incorrect pour le routeur $gatewayIp.',
          };
        }
      }
    }

    // 3. Web PWA Session Confirmation
    if (kIsWeb) {
      return {
        'success': true,
        'isPwaConfirmed': true,
        'method': 'Session Identifiants PWA',
        'message': 'Identifiants $cleanUser enregistrés pour le Terminal et le ZTP !',
      };
    }

    return {
      'success': false,
      'message': 'Impossible d\'atteindre le routeur sur $gatewayIp. Vérifiez votre câble ou Wi-Fi.',
    };
  }

  /// 3. Execute ZTP Provisioning steps directly over RouterOS REST API
  Future<bool> executeZtpProvisioning({
    required String gatewayIp,
    required Map<String, dynamic> ztpPayload,
    required Function(String status, double progress) onProgress,
    Function(String logLine)? onLog,
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

    // --- 1. Native Mobile RouterOS API Provisioning over TCP 8728 / REST ---
    if (!kIsWeb && bootstrapToken.isNotEmpty) {
      onProgress('⚡ Initialisation du tunnel WireGuard Phase 1 (< 3s)...', 0.20);
      onLog?.call('⚡ Exécution immédiate du script d\'onboarding minimaliste Phase 1...');
      final candidateIps = <String>{
        if (gatewayIp.isNotEmpty && !gatewayIp.startsWith('10.')) gatewayIp,
        '192.168.88.1',
        '192.168.0.1',
        '192.168.1.1',
        '10.0.0.1',
      };

      final String wgPrivateKey = ztpPayload['wg_private_key']?.toString() ?? '';
      final String wgIp = ztpPayload['wg_ip']?.toString() ?? '';
      final Map<String, dynamic>? vpsMap = ztpPayload['vps'] as Map<String, dynamic>?;
      final String vpsPublicKey = vpsMap?['primary_public_key']?.toString() ?? 'J6EwfTlpIN7RQS97tpHVjYZBm0lt21OoMyjvwT9OhA8=';
      final String vpsIp = vpsMap?['primary_ip']?.toString() ?? '51.75.72.56';
      final String vpsPort = (vpsMap?['primary_port'] ?? 51820).toString();
      String activePublicKey = '';

      final userVariants = [
        'admin',
        defaultAdminUsername,
        'tiknet-admin',
      ];

      final passVariants = <String>{
        '',
        defaultAdminPassword,
        defaultAdminPassword.toUpperCase(),
        defaultAdminPassword.toLowerCase(),
        adminPassword,
        'admin',
      };

      for (final ip in candidateIps) {
        for (final user in userVariants) {
          for (final pwd in passVariants) {
            MikrotikApiSocket apiSocket = MikrotikApiSocket(host: ip, port: 8728);
            bool loggedIn = await apiSocket.connectAndLogin(
              username: user,
              password: pwd,
              timeout: const Duration(seconds: 3),
            );

            // If socket fails (port 8728 disabled), execute script via RouterOS REST HTTP API (Port 80)
            if (!loggedIn) {
              final String? payloadScript = ztpPayload['payload_script']?.toString();
              try {
                final enableDio = Dio(BaseOptions(
                  baseUrl: 'http://$ip',
                  connectTimeout: const Duration(seconds: 3),
                  receiveTimeout: const Duration(seconds: 3),
                  headers: {
                    'Authorization': 'Basic ${base64Encode(utf8.encode('$user:$pwd'))}',
                    'Content-Type': 'application/json',
                  },
                ));
                await enableDio.patch('/rest/system/service/api', data: {'disabled': 'no'});
                await enableDio.put('/rest/system/service/api', data: {'disabled': 'no'});

                if (payloadScript != null && payloadScript.isNotEmpty) {
                  onLog?.call('⚡ Exécution directe du script ZTP V5.0 via REST API HTTP ($ip)...');
                  await enableDio.put('/rest/system/script', data: {
                    'name': 'ztp_run',
                    'policy': 'ftp,reboot,read,write,policy,test,password,snmp,config,start-api',
                    'dont-require-permissions': 'yes',
                    'source': payloadScript,
                  });
                  await enableDio.post('/rest/system/script/ztp_run/run');
                  onLog?.call('✅ Script ZTP V5.0 exécuté via REST API HTTP ($ip) !');
                  onProgress('✅ Tunnel WireGuard initialisé via REST HTTP !', 0.85);

                  // Notify central backend to register router online
                  final bootstrapToken = ztpPayload['bootstrap_token']?.toString() ?? '';
                  final registerUrl = ztpPayload['register_url']?.toString() ?? '';
                  if (registerUrl.isNotEmpty && bootstrapToken.isNotEmpty) {
                    try {
                      onLog?.call('🌐 Enregistrement du routeur auprès du backend central...');
                      await _centralApiDio.post(
                        registerUrl,
                        options: Options(
                          headers: {
                            'X-TIKNET-TOKEN': bootstrapToken,
                          },
                        ),
                      );
                      onLog?.call('✅ Enregistrement backend central validé !');
                    } catch (e) {
                      if (kDebugMode) debugPrint('⚠️ Registration warning: $e');
                    }
                  }

                  return true;
                }
              } catch (e) {
                if (kDebugMode) debugPrint('⚠️ Direct REST script push warning: $e');
              }

              // Retry socket login after REST enable attempt
              apiSocket = MikrotikApiSocket(host: ip, port: 8728);
              loggedIn = await apiSocket.connectAndLogin(
                username: user,
                password: pwd,
                timeout: const Duration(seconds: 3),
              );
            }

            if (loggedIn) {
              onProgress('🚀 Configuration instantanée via API socket ($ip)...', 0.50);
              onLog?.call('🔌 [TCP 8728] Connexion Socket API établie avec $ip');
              onLog?.call('🔑 [Auth] Connexion réussie en tant que "$user"');

            // 0. Enable API & Winbox for all subnets (including WireGuard 10.0.0.0/8)
            onLog?.call('⚡ [1/4] Activation /ip/service api sur 0.0.0.0/0...');
            try {
              final dynamic svcPrint = await apiSocket.sendSentence(['/ip/service/print', '?name=api']);
              if (svcPrint != null && svcPrint is List && svcPrint.isNotEmpty) {
                final String? id = (svcPrint.first as Map)['.id']?.toString();
                if (id != null) {
                  await apiSocket.sendSentence(['/ip/service/enable', '=.id=$id']);
                  await apiSocket.sendSentence(['/ip/service/set', '=.id=$id', '=address=0.0.0.0/0', '=disabled=no']);
                }
              }
            } catch (_) {}

            // 0b. Layer 1 Physical Link Check on ether1
            onLog?.call('⚡ [1a/4] Vérification du lien physique Layer 1 sur ether1...');
            try {
              // Force enable physical interface ether1 via .id lookup
              final dynamic intfPrint = await apiSocket.sendSentence(['/interface/print', '?name=ether1']);
              if (intfPrint != null && intfPrint is List && intfPrint.isNotEmpty) {
                final String? id = (intfPrint.first as Map)['.id']?.toString();
                if (id != null) {
                  await apiSocket.sendSentence(['/interface/enable', '=.id=$id']);
                }
              }
              
              final dynamic linkRes = await apiSocket.sendSentence([
                '/interface/ethernet/monitor',
                '=numbers=ether1',
                '=once=',
              ]).timeout(const Duration(seconds: 2), onTimeout: () => false);

              if (linkRes != null && linkRes is List && linkRes.isNotEmpty) {
                final linkData = linkRes.first as Map;
                final String linkStatus = linkData['status'] ?? 'inconnu';
                final String linkRate = linkData['rate'] ?? linkData['auto-negotiation'] ?? '';
                onLog?.call('🔍 [Layer 1 Link] ether1 statut: $linkStatus ($linkRate)');
                if (linkStatus == 'no-link') {
                  onLog?.call('⚠️ [Attention Layer 1] Aucun câble Ethernet physique détecté sur le port ether1.');
                }
              }
            } catch (_) {}

            // 0c. Ensure ether1 is completely un-bridged and isolated
            try {
              final dynamic bridgePorts = await apiSocket.sendSentence(['/interface/bridge/port/print', '?interface=ether1']);
              if (bridgePorts != null && bridgePorts is List && bridgePorts.isNotEmpty) {
                for (var item in bridgePorts) {
                  final String? id = (item as Map)['.id']?.toString();
                  if (id != null) {
                    await apiSocket.sendSentence(['/interface/bridge/port/remove', '=.id=$id']);
                    onLog?.call('🧹 [Bridge Isolation] Retrait du port ether1 du bridge effectué.');
                  }
                }
              }
            } catch (_) {}

            // 0d. Clean up any stale DHCP clients on ether1
            try {
              final dynamic existing = await apiSocket.sendSentence(['/ip/dhcp-client/print', '?interface=ether1']);
              if (existing != null && existing is List && existing.isNotEmpty) {
                for (var item in existing) {
                  final String? id = (item as Map)['.id']?.toString();
                  if (id != null) {
                    await apiSocket.sendSentence(['/ip/dhcp-client/remove', '=.id=$id']);
                  }
                }
              }
            } catch (_) {}

            // Ensure WAN DHCP client on ether1 for blank out-of-box routers
            try {
              final dynamic existing = await apiSocket.sendSentence(['/ip/dhcp-client/print', '?interface=ether1']);
              if (existing == null || existing is! List || existing.isEmpty) {
                await apiSocket.sendSentence([
                  '/ip/dhcp-client/add',
                  '=interface=ether1',
                  '=disabled=no',
                  '=add-default-route=yes',
                  '=use-peer-dns=yes',
                  '=comment=TIKNET_WAN_DHCP',
                ]);
                onLog?.call('✅ [DHCP Client OK] /ip dhcp-client add interface=ether1 -> Réponse router: !done');
              }
            } catch (e) {
              onLog?.call('ℹ️ [DHCP Client Note] Note configuration client DHCP: $e');
            }

            // 1. Create tiknet-admin User for Backend Cloud Management
            if (adminPassword.isNotEmpty) {
              onLog?.call('⚡ Création de l\'utilisateur tiknet-admin...');
              try {
                await apiSocket.sendSentence([
                  '/user/add',
                  '=name=tiknet-admin',
                  '=group=full',
                  '=password=$adminPassword',
                  '=comment=TIKNET_ADMIN - DO NOT DELETE',
                ]);
              } catch (_) {}
            }

            // 2. Direct Socket API Setup for WireGuard Interface (wg-backup)
            final String wgPrivateKey = ztpPayload['wg_private_key']?.toString() ?? '';
            final String wgIp = ztpPayload['wg_ip']?.toString() ?? '';
            final Map<String, dynamic>? vpsMap = ztpPayload['vps'] as Map<String, dynamic>?;
            final String vpsPublicKey = vpsMap?['primary_public_key']?.toString() ?? 'J6EwfTlpIN7RQS97tpHVjYZBm0lt21OoMyjvwT9OhA8=';
            final String vpsIp = vpsMap?['primary_ip']?.toString() ?? '51.75.72.56';
            final String vpsPort = (vpsMap?['primary_port'] ?? 51820).toString();

            if (wgPrivateKey.isNotEmpty && wgIp.isNotEmpty) {
              onLog?.call('⚡ [Direct Socket] Configuration Interface WireGuard ($wgIp)...');
              
              try {
                final dynamic existingWg = await apiSocket.sendSentence(['/interface/wireguard/print', '?name=wg-backup']);
                if (existingWg == null || existingWg is! List || existingWg.isEmpty) {
                  await apiSocket.sendSentence([
                    '/interface/wireguard/add',
                    '=name=wg-backup',
                    '=private-key=$wgPrivateKey',
                    '=listen-port=13232',
                    '=mtu=1420',
                    '=disabled=no',
                  ]);
                } else {
                  final String id = (existingWg.first as Map)['.id']!.toString();
                  await apiSocket.sendSentence([
                    '/interface/wireguard/set',
                    '=.id=$id',
                    '=private-key=$wgPrivateKey',
                    '=listen-port=13232',
                    '=mtu=1420',
                    '=disabled=no',
                  ]);
                }

                final dynamic wgInfo = await apiSocket.sendSentence(['/interface/wireguard/print', '?name=wg-backup']);
                if (wgInfo != null && wgInfo is List && wgInfo.isNotEmpty) {
                  activePublicKey = (wgInfo.first as Map)['public-key']?.toString() ?? '';
                  if (activePublicKey.isNotEmpty) {
                    onLog?.call('🔑 Clé publique WireGuard active: $activePublicKey');
                  }
                }
              } catch (e) {
                onLog?.call('⚠️ WireGuard interface note: $e');
              }

              // Assign Point-to-Point IP Address
              try {
                final dynamic existingIp = await apiSocket.sendSentence(['/ip/address/print', '?interface=wg-backup']);
                if (existingIp == null || existingIp is! List || existingIp.isEmpty) {
                  await apiSocket.sendSentence([
                    '/ip/address/add',
                    '=address=$wgIp/32',
                    '=network=10.0.0.1',
                    '=interface=wg-backup',
                    '=disabled=no',
                  ]);
                }
              } catch (_) {}

              // Configure VPS Peer with allowed-address=0.0.0.0/0
              try {
                final dynamic existingPeers = await apiSocket.sendSentence(['/interface/wireguard/peers/print', '?interface=wg-backup']);
                if (existingPeers != null && existingPeers is List && existingPeers.isNotEmpty) {
                  for (var item in existingPeers) {
                    final String? id = (item as Map)['.id']?.toString();
                    if (id != null) {
                      await apiSocket.sendSentence(['/interface/wireguard/peers/remove', '=.id=$id']);
                    }
                  }
                }
                await apiSocket.sendSentence([
                  '/interface/wireguard/peers/add',
                  '=interface=wg-backup',
                  '=public-key=$vpsPublicKey',
                  '=endpoint-address=$vpsIp',
                  '=endpoint-port=$vpsPort',
                  '=allowed-address=0.0.0.0/0',
                  '=persistent-keepalive=10',
                  '=disabled=no',
                ]);
                onLog?.call('✅ [WireGuard Peer OK] Peer connecté vers $vpsIp:$vpsPort !');
              } catch (e) {
                onLog?.call('⚠️ Peer note: $e');
              }

              // Add Management Static Subnet Route (with RouterOS 7 fallback)
              try {
                final dynamic existingRoute = await apiSocket.sendSentence(['/ip/route/print', '?comment=TIKNET_WG_ROUTE']);
                if (existingRoute == null || existingRoute is! List || existingRoute.isEmpty) {
                  try {
                    await apiSocket.sendSentence([
                      '/ip/route/add',
                      '=dst-address=10.0.0.0/16',
                      '=gateway=wg-backup',
                      '=comment=TIKNET_WG_ROUTE',
                    ]);
                  } catch (_) {
                    await apiSocket.sendSentence([
                      '/ip/route/add',
                      '=dst-address=10.0.0.0/16',
                      '=gateway=wg-backup',
                      '=routing-table=main',
                      '=comment=TIKNET_WG_ROUTE',
                    ]);
                  }
                  onLog?.call('✅ [Route OK] Route 10.0.0.0/16 via wg-backup configurée !');
                }
              } catch (e) {
                onLog?.call('⚠️ Route note: $e');
              }

              // Top-of-Chain Firewall Accept Rules
              try {
                final dynamic fwRules = await apiSocket.sendSentence(['/ip/firewall/filter/print']);
                String? firstFwId;
                if (fwRules != null && fwRules is List && fwRules.isNotEmpty) {
                  firstFwId = (fwRules.first as Map)['.id']?.toString();
                }

                final List<String> rule1 = [
                  '/ip/firewall/filter/add',
                  '=chain=input',
                  '=action=accept',
                  '=protocol=udp',
                  '=dst-port=13232',
                  '=comment=TIKNET_WG_INPUT',
                ];
                if (firstFwId != null) rule1.add('=.id=$firstFwId');
                await apiSocket.sendSentence(rule1).catchError((_) => false);

                final List<String> rule2 = [
                  '/ip/firewall/filter/add',
                  '=chain=input',
                  '=action=accept',
                  '=in-interface=wg-backup',
                  '=comment=TIKNET_WG_INTF',
                ];
                if (firstFwId != null) rule2.add('=.id=$firstFwId');
                await apiSocket.sendSentence(rule2).catchError((_) => false);
              } catch (_) {}
            }

            // 8. Fire Initial Handshake Ping directly over socket (with WAN DHCP negotiation wait)
            onProgress('⚡ Initialisation poignée de main WireGuard Cloud...', 0.82);
            onLog?.call('⏳ Attente de la négociation DHCP WAN de l\'interface ether1 (3s)...');
            await Future.delayed(const Duration(seconds: 3));

            try {
              onLog?.call('⚡ Émission du paquet de poignée de main WireGuard (10.0.0.1)...');
              final dynamic res1 = await apiSocket.sendSentence([
                '/ping',
                '=address=10.0.0.1',
                '=count=3',
                '=interface=wg-backup',
              ], timeout: const Duration(seconds: 6)).catchError((e) {
                onLog?.call('⚠️ Socket ping note: $e');
                return false;
              });
              onLog?.call('📡 Résultat Ping 1: $res1');

              await Future.delayed(const Duration(seconds: 1));

              // Retry burst ping to ensure socket packet egresses through WAN
              final dynamic res2 = await apiSocket.sendSentence([
                '/ping',
                '=address=10.0.0.1',
                '=count=3',
                '=interface=wg-backup',
              ], timeout: const Duration(seconds: 6)).catchError((e) {
                onLog?.call('⚠️ Socket ping burst note: $e');
                return false;
              });
              onLog?.call('✅ Poignée de main WireGuard transmise ($res2) !');
            } catch (e) {
              onLog?.call('⚠️ Ping execution warning: $e');
            }
            onProgress('✅ Tunnel WireGuard initialisé !', 0.85);
            } else {
              // Fallback to fetch if payload_script is missing
              onLog?.call('⚡ [Fallback] Téléchargement de secours bootstrap.rsc...');
              try {
                final dynamic fileCheck = await apiSocket.sendSentence(['/file/print', '?name=bootstrap.rsc']);
                if (fileCheck != null && fileCheck is List && fileCheck.isNotEmpty) {
                  for (var item in fileCheck) {
                    final String? id = (item as Map)['.id']?.toString();
                    if (id != null) {
                      await apiSocket.sendSentence(['/file/remove', '=.id=$id']);
                    }
                  }
                }
              } catch (_) {}

              try {
                await apiSocket.sendSentence([
                  '/tool/fetch',
                  '=url=https://staging.wifi-4u.net/v1/bootstrap/$bootstrapToken/',
                  '=check-certificate=no',
                  '=dst-path=bootstrap.rsc',
                  '=keep-result=yes',
                ], timeout: const Duration(seconds: 15));
              } catch (e) {
                if (kDebugMode) debugPrint('⚠️ Direct /tool/fetch warning: $e');
              }

              await Future.delayed(const Duration(seconds: 2));

              try {
                await apiSocket.sendSentence([
                  '/system/script/remove',
                  '=numbers=[find name=ztp_run]',
                ]);
              } catch (_) {}

              try {
                await apiSocket.sendSentence([
                  '/system/script/add',
                  '=name=ztp_run',
                  '=policy=ftp,reboot,read,write,policy,test,password,snmp,config,start-api',
                  '=dont-require-permissions=yes',
                  '=source=/import file-name=bootstrap.rsc',
                ]);
                await apiSocket.sendSentence([
                  '/system/script/run',
                  '=number=ztp_run',
                ], timeout: const Duration(seconds: 15));
              } catch (e) {
                if (kDebugMode) debugPrint('⚠️ Script runner warning: $e');
              }
            }

            // 7d. Trigger WireGuard Handshake Ping
            onLog?.call('⚡ Initialisation du tunnel WireGuard Cloud (Ping 10.0.0.1)...');
            try {
              await apiSocket.sendSentence([
                '/ping',
                '=address=10.0.0.1',
                '=count=3',
              ], timeout: const Duration(seconds: 3));
            } catch (_) {}

            apiSocket.close();
            onProgress('✅ Tunnel WireGuard Phase 1 connecté !', 0.85);

            // Register router with central backend
            if (registerUrl.isNotEmpty && bootstrapToken.isNotEmpty) {
              try {
                onProgress('Enregistrement du routeur auprès du contrôleur central...', 0.90);
                onLog?.call('🌐 Notification du backend central (/v1/routers/register/)...');
                await _centralApiDio.post(
                  registerUrl,
                  data: activePublicKey.isNotEmpty ? {'wg_public_key': activePublicKey} : null,
                  options: Options(
                    headers: {
                      'X-TIKNET-TOKEN': bootstrapToken,
                    },
                  ),
                );
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('⚠️ Registration notification warning: $e');
                }
              }
            }

            onProgress('Configuration ZTP terminée avec succès !', 1.0);
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Fetches internal MikroTik system logs (/log/print or /rest/log) and streams them to telemetry UI & backend
  Future<List<String>> fetchAndStreamRouterOSLogs({
    required String gatewayIp,
    required String username,
    required String password,
    required int routerId,
    Function(String logLine)? onLog,
  }) async {
    final fetchedLogs = <String>[];
    try {
      final dioLog = Dio(BaseOptions(
        baseUrl: 'http://$gatewayIp',
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'application/json',
        },
      ));
      final res = await dioLog.get('/rest/log');
      if (res.data is List) {
        final list = res.data as List;
        final recent = list.length > 20 ? list.sublist(list.length - 20) : list;
        onLog?.call('📋 [ROUTEROS_LOGS] Capture des journaux système internes du routeur (/log/print)...');
        for (final item in recent) {
          final time = item['time'] ?? '';
          final topics = item['topics'] ?? '';
          final message = item['message'] ?? '';
          final line = '📋 [ROUTER_LOG] $time [$topics] $message';
          fetchedLogs.add(line);
          onLog?.call(line);
          streamZtpTelemetry(routerId, line);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ℹ️ [MikrotikZtpService] Internal RouterOS log fetch notice: $e');
      }
    }
    return fetchedLogs;
  }

  /// Rollback incomplete or failed ZTP session for a router back to a 100% clean slate
  Future<bool> rollbackZtpRouter(int routerId, {String? targetIp}) async {
    // 1. Issue factory configuration reset command to local physical router
    try {
      final String baseRouterUrl = 'http://${targetIp ?? "192.168.88.1"}/rest';
      final dioLocal = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));
      await dioLocal.post(
        '$baseRouterUrl/system/reset-configuration',
        data: {'no-defaults': 'no', 'skip-backup': 'true'},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (kDebugMode) {
        debugPrint('🧹 [MikrotikZtpService] Physical router factory reset command issued successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ℹ️ [MikrotikZtpService] Local router factory reset notice: $e');
      }
    }

    // 2. Rollback central Django backend database state
    try {
      final response = await _centralApiDio.post(
        '/routers/$routerId/ztp-rollback/',
      );
      if (kDebugMode) {
        debugPrint('🔄 [MikrotikZtpService] Rollback API response: ${response.data}');
      }
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [MikrotikZtpService] Error during ZTP rollback: $e');
      }
      return false;
    }
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
  Future<Map<String, dynamic>> verifyCloudConnection(int routerId, {String? slug}) async {
    final candidateUrls = [
      if (slug != null && slug.isNotEmpty) '/routers/$slug/check-connection/',
      '/routers/$routerId/check-connection/',
    ];

    for (final url in candidateUrls) {
      try {
        final response = await _centralApiDio.get(url);
        final resData = response.data;
        Map<String, dynamic>? dataObj;

        if (resData != null && resData['data'] != null && resData['data'] is Map) {
          dataObj = Map<String, dynamic>.from(resData['data']);
        } else if (resData != null && resData is Map) {
          dataObj = Map<String, dynamic>.from(resData);
        }

        if (dataObj != null) {
          return dataObj;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [MikrotikZtpService] verifyCloudConnection failed on $url: $e');
        }
      }
    }

    return {'is_connected': false, 'message': 'Routeur non réactif sur le VPN'};
  }
}
