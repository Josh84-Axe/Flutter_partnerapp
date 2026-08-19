import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Silent, CORS-bypassing Web ZTP helper for PWA running on HTTPS.
/// Uses mode:'no-cors' fetch & navigator.sendBeacon to dispatch REST commands
/// silently WITHOUT triggering browser Form Submission popups or DOM dialogs.
void _sendSilentNoCorsRequest(String url, String jsonBody) {
  try {
    // 1. Silent navigator.sendBeacon (Supported in all modern mobile browsers)
    try {
      final blob = html.Blob([jsonBody], 'application/json');
      html.window.navigator.sendBeacon(url, blob);
    } catch (_) {}

    // 2. Silent Fetch API with mode: 'no-cors' (Bypasses CORS preflight and form dialogs)
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
}) async {
  try {
    if (kDebugMode) {
      debugPrint('⚡ [WebZtpHelper] Executing Silent Web ZTP to $gatewayIp...');
    }

    final bootstrapUrl = 'https://staging.wifi-4u.net/v1/bootstrap/$bootstrapToken/';

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

      await Future.delayed(const Duration(milliseconds: 1000));

      // 2. Payload 2: /rest/system/script (Create import script)
      final json2 = jsonEncode({
        'name': 'import-bootstrap-script',
        'source': '/import file-name=bootstrap.rsc',
      });
      _sendSilentNoCorsRequest('$host/rest/system/script', json2);

      await Future.delayed(const Duration(milliseconds: 800));

      // 3. Payload 3: /rest/system/script/import-bootstrap-script/run (Execute import script)
      final json3 = jsonEncode({});
      _sendSilentNoCorsRequest('$host/rest/system/script/import-bootstrap-script/run', json3);

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
