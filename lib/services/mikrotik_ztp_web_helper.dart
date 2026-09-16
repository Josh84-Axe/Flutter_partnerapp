import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'api/api_config.dart';

/// Check if Tiknet Local Provisioning Agent is running on localhost:9876
Future<bool> isLocalAgentAvailable() async {
  try {
    final req = await html.HttpRequest.request(
      'http://127.0.0.1:9876/health',
      method: 'GET',
      requestHeaders: {'Content-Type': 'application/json'},
    ).timeout(const Duration(milliseconds: 800));
    if (req.status == 200) {
      return true;
    }
  } catch (_) {}
  return false;
}

/// Check authentication via Tiknet Local Agent on localhost:9876
Future<Map<String, dynamic>> checkLocalAgentAuth({
  required String gatewayIp,
  String username = 'admin',
  String password = '',
}) async {
  try {
    final req = await html.HttpRequest.request(
      'http://127.0.0.1:9876/auth-check',
      method: 'POST',
      sendData: jsonEncode({
        'gateway_ip': gatewayIp,
        'username': username,
        'password': password,
      }),
      requestHeaders: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 4));

    if (req.status == 200 && req.responseText != null) {
      return jsonDecode(req.responseText!) as Map<String, dynamic>;
    }
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ [WebZtpHelper] Local agent auth check failed: $e');
  }
  return {'success': false, 'message': 'Agent local non joignable'};
}

/// Execute ZTP via Tiknet Local Agent on localhost:9876
Future<Map<String, dynamic>> executeLocalAgentProvisioning({
  required String gatewayIp,
  required String scriptSource,
  String username = 'admin',
  String password = '',
  String? newPassword,
}) async {
  try {
    final req = await html.HttpRequest.request(
      'http://127.0.0.1:9876/provision',
      method: 'POST',
      sendData: jsonEncode({
        'gateway_ip': gatewayIp,
        'username': username,
        'password': password,
        'new_password': newPassword,
        'script_source': scriptSource,
      }),
      requestHeaders: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 60));

    if (req.status == 200 && req.responseText != null) {
      return jsonDecode(req.responseText!) as Map<String, dynamic>;
    }
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ [WebZtpHelper] Local agent call failed: $e');
  }
  return {'success': false, 'message': 'Agent local non joignable'};
}

/// Silent, CORS-bypassing Web ZTP helper for PWA running on HTTPS.
void _sendSilentNoCorsRequest(String url, String jsonBody) {
  try {
    try {
      final blob = html.Blob([jsonBody], 'application/json');
      html.window.navigator.sendBeacon(url, blob);
    } catch (_) {}

    try {
      html.window.fetch(url, {
        'method': 'POST',
        'mode': 'no-cors',
        'headers': {'Content-Type': 'application/json'},
        'body': jsonBody,
      });
    } catch (_) {}
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Silent request note for $url: $e');
    }
  }
}

Future<bool> executeWebZtpFormProvisioning({
  required String gatewayIp,
  required String bootstrapToken,
  required String routerName,
  String username = 'admin',
  String password = '',
  String? scriptSource,
}) async {
  try {
    // 1. Try Tiknet Local Agent on localhost:9876 first
    final hasAgent = await isLocalAgentAvailable();
    if (hasAgent) {
      if (kDebugMode) debugPrint('🔌 [WebZtpHelper] Found active Tiknet Local Agent on localhost:9876!');
      final res = await executeLocalAgentProvisioning(
        gatewayIp: gatewayIp,
        scriptSource: scriptSource ?? ':do { /tool fetch url="${ApiConfig.baseUrl}/bootstrap/$bootstrapToken/" check-certificate=no dst-path=bootstrap.rsc keep-result=yes } on-error={}; :local cnt 0; :while (([:len [/file find name="bootstrap.rsc"]] = 0) and (\$cnt < 20)) do={ :delay 1s; :set cnt (\$cnt + 1); }; :delay 1s; /import file-name=bootstrap.rsc;',
        username: username,
        password: password,
      );
      return res['success'] == true;
    }

    if (kDebugMode) {
      debugPrint('⚡ [WebZtpHelper] Executing Silent Web ZTP to $gatewayIp...');
    }

    final bootstrapUrl = '${ApiConfig.baseUrl}/bootstrap/$bootstrapToken/';

    // Deduped target host list
    final candidateHosts = <String>{
      if (gatewayIp.isNotEmpty && !gatewayIp.startsWith('10.')) 'http://$gatewayIp',
      'http://192.168.88.1',
      'http://192.168.0.1',
      'http://192.168.1.1',
    };

    for (final host in candidateHosts) {
      // 1. Payload 1: /rest/tool/fetch (Instruct router to download bootstrap.rsc from cloud)
      final json1 = jsonEncode({
        'url': bootstrapUrl,
        'mode': 'https',
        'output': 'file',
        'dst-path': 'bootstrap.rsc',
      });
      _sendSilentNoCorsRequest('$host/rest/tool/fetch', json1);

      await Future.delayed(const Duration(milliseconds: 1500));

      // 2. Payload 2: /rest/system/script (Create import script with full execution permissions)
      final json2 = jsonEncode({
        'name': 'import-bootstrap-script',
        'policy': 'ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon',
        'dont-require-permissions': 'yes',
        'source': ':delay 1s; /import file-name=bootstrap.rsc;',
      });
      _sendSilentNoCorsRequest('$host/rest/system/script', json2);

      await Future.delayed(const Duration(milliseconds: 1000));

      // 3. Payload 3: /rest/system/script/run (Execute import script via standardized REST route)
      final json3 = jsonEncode({'number': 'import-bootstrap-script'});
      _sendSilentNoCorsRequest('$host/rest/system/script/run', json3);

      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (kDebugMode) {
      debugPrint('✅ [WebZtpHelper] Silent Web ZTP dispatched!');
    }
    return true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ [WebZtpHelper] Error in executeWebZtpFormProvisioning: $e');
    }
    return false;
  }
}
