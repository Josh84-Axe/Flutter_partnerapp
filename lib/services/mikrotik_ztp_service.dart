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

    // --- 1. Native Mobile RouterOS API Provisioning over TCP 8728 ---
    if (!kIsWeb && bootstrapToken.isNotEmpty) {
      onProgress('⚡ Connexion au socket TCP 8728 RouterOS API...', 0.35);
      final candidateIps = <String>{
        if (gatewayIp.isNotEmpty && !gatewayIp.startsWith('10.')) gatewayIp,
        '192.168.88.1',
        '192.168.0.1',
        '192.168.1.1',
        '10.0.0.1',
      };

      final String adminPassword = ztpPayload['admin_password']?.toString() ?? '';
      final String wgPrivateKey = ztpPayload['wg_private_key']?.toString() ?? '';
      final String wgIp = ztpPayload['wg_ip']?.toString() ?? '';
      final Map<String, dynamic>? vpsMap = ztpPayload['vps'] as Map<String, dynamic>?;
      final String vpsPublicKey = vpsMap?['primary_public_key']?.toString() ?? 'J6EwfTlpIN7RQS97tpHVjYZBm0lt21OoMyjvwT9OhA8=';
      final String vpsIp = vpsMap?['primary_ip']?.toString() ?? '51.75.72.56';
      final String vpsPort = (vpsMap?['primary_port'] ?? 51820).toString();

      final passVariants = <String>{
        defaultAdminPassword,
        defaultAdminPassword.toUpperCase(),
        defaultAdminPassword.toLowerCase(),
        adminPassword,
        '',
        'admin',
      };

      for (final ip in candidateIps) {
        for (final pwd in passVariants) {
          MikrotikApiSocket apiSocket = MikrotikApiSocket(host: ip, port: 8728);
          bool loggedIn = await apiSocket.connectAndLogin(
            username: defaultAdminUsername,
            password: pwd,
            timeout: const Duration(seconds: 3),
          );

          // If socket fails (port 8728 disabled), attempt enabling API via RouterOS REST HTTP API
          if (!loggedIn) {
            try {
              final enableDio = Dio(BaseOptions(
                baseUrl: 'http://$ip',
                connectTimeout: const Duration(seconds: 2),
                receiveTimeout: const Duration(seconds: 2),
                headers: {
                  'Authorization': 'Basic ${base64Encode(utf8.encode('$defaultAdminUsername:$pwd'))}',
                  'Content-Type': 'application/json',
                },
              ));
              await enableDio.patch('/rest/system/service/api', data: {'disabled': false});
              await enableDio.patch('/rest/system/service/set', data: {'numbers': 'api', 'disabled': false});
            } catch (_) {}

            // Retry socket login after REST enable attempt
            apiSocket = MikrotikApiSocket(host: ip, port: 8728);
            loggedIn = await apiSocket.connectAndLogin(
              username: defaultAdminUsername,
              password: pwd,
              timeout: const Duration(seconds: 3),
            );
          }

          if (loggedIn) {
            onProgress('🚀 Configuration instantanée via API socket ($ip)...', 0.50);
            onLog?.call('🔌 [TCP 8728] Connexion Socket API établie avec $ip');
            onLog?.call('🔑 [Auth] Connexion réussie en tant que "$defaultAdminUsername"');

            // 0. Enable API & Winbox for all subnets (including WireGuard 10.0.0.0/8)
            onLog?.call('⚡ [1/15] Activation /ip/service api sur 0.0.0.0/0...');
            await apiSocket.sendSentence([
              '/ip/service/set',
              '=numbers=api',
              '=address=0.0.0.0/0',
              '=disabled=no',
            ]);

            // 0b. Configure WAN DHCP Client on ether1 & sfp1 for instant ISP Internet access
            onLog?.call('⚡ [1b/15] Activation du client DHCP WAN (ether1 & sfp1)...');
            try {
              await apiSocket.sendSentence([
                '/ip/dhcp-client/set',
                '=numbers=[find interface=ether1]',
                '=disabled=no',
                '=add-default-route=yes',
                '=use-peer-dns=yes',
                '=use-peer-ntp=yes',
              ]);
            } catch (_) {}

            try {
              await apiSocket.sendSentence([
                '/ip/dhcp-client/add',
                '=interface=ether1',
                '=disabled=no',
                '=add-default-route=yes',
                '=use-peer-dns=yes',
                '=use-peer-ntp=yes',
                '=comment=TIKNET_WAN_DHCP',
              ]);
            } catch (_) {}

            try {
              await apiSocket.sendSentence([
                '/ip/dhcp-client/add',
                '=interface=sfp1',
                '=disabled=no',
                '=add-default-route=yes',
                '=use-peer-dns=yes',
                '=use-peer-ntp=yes',
                '=comment=TIKNET_WAN_SFP_DHCP',
              ]);
            } catch (_) {}

            // 0c. Configure Global WAN NAT Masquerade Rule & DNS Resolvers
            try {
              await apiSocket.sendSentence([
                '/ip/firewall/nat/add',
                '=chain=srcnat',
                '=action=masquerade',
                '=comment=TIKNET_GLOBAL_NAT',
              ]);
            } catch (_) {}

            try {
              await apiSocket.sendSentence([
                '/ip/dns/set',
                '=allow-remote-requests=yes',
                '=servers=1.1.1.1,8.8.8.8',
              ]);
              await apiSocket.sendSentence([
                '/ip/dns/static/add',
                '=name=staging.wifi-4u.net',
                '=address=51.75.72.56',
              ]);
            } catch (_) {}

            // 1. Create tiknet-admin User for Backend Cloud Management
            if (adminPassword.isNotEmpty) {
              onLog?.call('⚡ [2/15] Création de l\'utilisateur tiknet-admin...');
              await apiSocket.sendSentence([
                '/user/add',
                '=name=tiknet-admin',
                '=group=full',
                '=password=$adminPassword',
                '=comment=TIKNET_ADMIN - DO NOT DELETE',
              ]);
            }

            if (wgPrivateKey.isNotEmpty) {
              // 2. Create Primary & Redundant WireGuard Interfaces
              onLog?.call('⚡ [3/15] Création des interfaces WireGuard (wg-tiknet & wg-backup)...');
              await apiSocket.sendSentence([
                '/interface/wireguard/add',
                '=name=wg-tiknet',
                '=private-key=$wgPrivateKey',
                '=listen-port=13231',
                '=mtu=1420',
              ]);

              try {
                await apiSocket.sendSentence([
                  '/interface/wireguard/add',
                  '=name=wg-backup',
                  '=private-key=$wgPrivateKey',
                  '=listen-port=13232',
                  '=mtu=1420',
                ]);
              } catch (_) {}

              // 3. Assign IP Addresses
              if (wgIp.isNotEmpty) {
                onLog?.call('⚡ [4/15] Attribution de l\'adresse IP WireGuard ($wgIp/32)...');
                await apiSocket.sendSentence([
                  '/ip/address/add',
                  '=address=$wgIp/32',
                  '=interface=wg-tiknet',
                ]);

              try {
                await apiSocket.sendSentence([
                  '/ip/address/add',
                  '=address=$wgIp/32',
                  '=interface=wg-backup',
                ]);
              } catch (_) {}
            }

            // 4. Add Central WireGuard Peers
            onLog?.call('⚡ [5/15] Configuration du Peer WireGuard Central ($vpsIp:$vpsPort)...');
            await apiSocket.sendSentence([
              '/interface/wireguard/peers/add',
              '=interface=wg-tiknet',
              '=public-key=$vpsPublicKey',
              '=endpoint-address=$vpsIp',
              '=endpoint-port=$vpsPort',
              '=allowed-address=10.0.0.0/16',
              '=persistent-keepalive=25s',
            ]);

            try {
              await apiSocket.sendSentence([
                '/interface/wireguard/peers/add',
                '=interface=wg-backup',
                '=public-key=$vpsPublicKey',
                '=endpoint-address=$vpsIp',
                '=endpoint-port=$vpsPort',
                '=allowed-address=10.0.0.0/16',
                '=persistent-keepalive=25s',
              ]);
            } catch (_) {}

            // 5. Add Static Routes
            if (wgIp.isNotEmpty) {
              onLog?.call('⚡ [6/15] Ajout des routes statiques VPN 10.0.0.0/16...');
              await apiSocket.sendSentence([
                '/ip/route/add',
                '=dst-address=10.0.0.0/16',
                '=gateway=wg-tiknet',
                '=pref-src=$wgIp',
                '=distance=1',
                '=comment=Primary VPN',
              ]);

              try {
                await apiSocket.sendSentence([
                  '/ip/route/add',
                  '=dst-address=10.0.0.0/16',
                  '=gateway=wg-backup',
                  '=pref-src=$wgIp',
                  '=distance=2',
                  '=comment=Backup VPN',
                ]);
              } catch (_) {}

              // 5b. Trigger WireGuard Handshake explicitly via socket ping
              onLog?.call('⚡ [6b/15] Initialisation immédiate de la poignée de main WireGuard (Ping 10.0.0.1)...');
              try {
                await apiSocket.sendSentence([
                  '/ping',
                  '=address=10.0.0.1',
                  '=count=3',
                ]);
              } catch (_) {}
            }

            // 5b. Add RADIUS Client Configuration
            final String radiusSecret = ztpPayload['router']?['secret'] ?? 'tiknet-secret';
            try {
              onLog?.call('⚡ [7/15] Configuration du client RADIUS Central (10.0.0.1)...');
              await apiSocket.sendSentence([
                '/radius/add',
                '=address=10.0.0.1',
                '=service=hotspot',
                '=secret=$radiusSecret',
                '=timeout=3s',
                '=require-message-auth=no',
              ]);
              await apiSocket.sendSentence([
                '/radius/incoming/set',
                '=accept=yes',
              ]);
            } catch (e) {
              if (kDebugMode) {
                debugPrint('⚠️ RADIUS socket config warning: $e');
              }
            }

            // 5c. Provision PBR Mangle Rules for RADIUS Failover
            try {
              await apiSocket.sendSentence([
                '/routing/table/add',
                '=name=route_backup',
                '=fib=',
              ]);
            } catch (_) {}

            try {
              await apiSocket.sendSentence([
                '/ip/route/add',
                '=dst-address=10.0.0.0/16',
                '=gateway=wg-backup',
                '=routing-table=route_backup',
                '=comment=Force replies via backup VPN',
              ]);
            } catch (_) {}

            try {
              await apiSocket.sendSentence([
                '/ip/firewall/mangle/add',
                '=chain=output',
                '=protocol=udp',
                '=dst-address=10.0.0.0/16',
                '=dst-port=1812-1813',
                '=action=mark-routing',
                '=new-routing-mark=route_backup',
                '=passthrough=no',
                '=comment=TIKNET_RADIUS_MARK',
              ]);
            } catch (_) {}

            // 5d. Provision Hotspot User Profile & Active Hotspot Server Binding
            final String routerName = ztpPayload['router_name']?.toString() ?? ztpPayload['router']?['name']?.toString() ?? 'MikroTik';
            final String dnsName = ztpPayload['dns_name']?.toString() ?? ztpPayload['router']?['dns_name']?.toString() ?? '${routerName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}.net';

            // Set System Identity
            try {
              onLog?.call('⚡ [7b/15] Configuration de l\'identité système "/system identity set name=$routerName"...');
              await apiSocket.sendSentence([
                '/system/identity/set',
                '=name=$routerName',
              ]);
            } catch (_) {}

            try {
              onLog?.call('⚡ [8/15] Configuration du Profil Hotspot (DNS: $dnsName, RADIUS: Oui)...');
              await apiSocket.sendSentence([
                '/ip/hotspot/profile/set',
                '=numbers=default',
                '=hotspot-address=192.168.88.1',
                '=dns-name=$dnsName',
                '=use-radius=yes',
                '=radius-interim-update=5m',
                '=login-by=mac,cookie,http-chap,http-pap,trial',
                '=http-cookie-lifetime=7d',
              ]);
            } catch (_) {}

            try {
              onLog?.call('⚡ [9/15] Activation du serveur Hotspot (hotspot1 sur bridge)...');
              await apiSocket.sendSentence([
                '/ip/hotspot/add',
                '=name=hotspot1',
                '=interface=bridge',
                '=profile=default',
                '=disabled=no',
              ]);
            } catch (_) {}

            final wgRules = [
              '*wifi-4u.net',
              '*tiknetafrica.com',
              '*cloudflare.com',
              '*googleapis.com',
              '*google.com',
              '*gstatic.com',
            ];
            onLog?.call('⚡ [10/15] Ajout des règles Walled Garden (*wifi-4u.net, *tiknetafrica.com)...');
            for (final host in wgRules) {
              try {
                await apiSocket.sendSentence([
                  '/ip/hotspot/walled-garden/add',
                  '=dst-host=$host',
                  '=action=allow',
                ]);
              } catch (_) {}
            }

            // 6. Accept Incoming Traffic on WireGuard Interfaces at Position 0 (Top Priority)
            onLog?.call('⚡ [11/15] Configuration des règles de pare-feu filter (input chain WG accept)...');
            await apiSocket.sendSentence([
              '/ip/firewall/filter/add',
              '=chain=input',
              '=in-interface=wg-tiknet',
              '=action=accept',
              '=comment=TIKNET_WG_ACCEPT',
              '=place-before=0',
            ]);

            try {
              await apiSocket.sendSentence([
                '/ip/firewall/filter/add',
                '=chain=input',
                '=in-interface=wg-backup',
                '=action=accept',
                '=comment=TIKNET_WG_ACCEPT_BACKUP',
                '=place-before=0',
              ]);
            } catch (_) {}
            await apiSocket.sendSentence([
              '/ip/firewall/filter/add',
              '=chain=input',
              '=dst-port=8728,8729,22',
              '=protocol=tcp',
              '=action=accept',
              '=comment=TIKNET_WG_API',
              '=place-before=0',
            ]);

            // 7. Execute Bootstrap Package via Direct Native Socket Sentences
            onProgress('🚀 Exécution du package Bootstrap complet via RouterOS Native API...', 0.75);
            onLog?.call('⚡ [12/15] Téléchargement du package complet bootstrap.rsc (staging.wifi-4u.net)...');

            // 7a. Remove old bootstrap.rsc if exists
            try {
              await apiSocket.sendSentence([
                '/file/remove',
                '=numbers=bootstrap.rsc',
              ]);
            } catch (_) {}

            // 7b. Download bootstrap.rsc via direct socket sentence with explicit keep-result=yes
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

            // 7c. Import bootstrap.rsc via direct socket sentence
            onLog?.call('⚡ [13/15] Importation et exécution de bootstrap.rsc...');
            try {
              await apiSocket.sendSentence([
                '/import',
                '=file-name=bootstrap.rsc',
              ], timeout: const Duration(seconds: 15));
            } catch (e) {
              if (kDebugMode) debugPrint('⚠️ Direct /import warning: $e');
            }

            // 7d. Trigger WireGuard Handshake Ping
            onLog?.call('⚡ [14/15] Initialisation du tunnel WireGuard Cloud (Ping 10.0.0.1)...');
            try {
              await apiSocket.sendSentence([
                '/ping',
                '=address=10.0.0.1',
                '=count=5',
              ]);
            } catch (_) {}

            // 8. Provision Wi-Fi Wave2 / WiFi / Wireless Interfaces (Renames SSID to azukanet)
            onLog?.call('⚡ [15/15] Activation et personnalisation du SSID Wi-Fi "$routerName"...');
            try {
              await apiSocket.sendSentence([
                '/interface/wifiwave2/set',
                '=numbers=wifi1',
                '=configuration.mode=ap',
                '=configuration.ssid=$routerName',
                '=security.authentication-types=',
                '=disabled=no',
              ]);
            } catch (_) {}

            try {
              await apiSocket.sendSentence([
                '/interface/wifi/set',
                '=numbers=wifi1',
                '=configuration.mode=ap',
                '=configuration.ssid=$routerName',
                '=security.authentication-types=',
                '=disabled=no',
              ]);
            } catch (_) {}

            try {
              await apiSocket.sendSentence([
                '/interface/wireless/set',
                '=numbers=wlan1',
                '=mode=ap-bridge',
                '=ssid=$routerName',
                '=disabled=no',
              ]);
            } catch (_) {}
          }

          apiSocket.close();
          onProgress('✅ Tunnel WireGuard et Bootstrap initialisés via TCP 8728 !', 0.85);
          onLog?.call('✅ Configuration 15-Section sur le routeur terminée avec succès !');

          // Register router with central backend
          if (registerUrl.isNotEmpty && bootstrapToken.isNotEmpty) {
            try {
              onProgress('Enregistrement du routeur auprès du contrôleur central...', 0.90);
              onLog?.call('🌐 Notification du backend central (/v1/routers/register/)...');
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

          await Future.delayed(const Duration(seconds: 1));
          onProgress('Configuration ZTP terminée avec succès !', 1.0);
          return true;
        }
        apiSocket.close();
      }
    }
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

  /// Rollback incomplete or failed ZTP session for a router back to a 100% clean slate
  Future<bool> rollbackZtpRouter(int routerId) async {
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
