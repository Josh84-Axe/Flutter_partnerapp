import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

Future<bool> executeWebZtpFormProvisioning({
  required String gatewayIp,
  required String bootstrapToken,
  required String routerName,
}) async {
  try {
    if (kDebugMode) {
      debugPrint('⚡ [WebZtpHelper] Executing JSON Beacon & fetch ZTP to $gatewayIp...');
    }

    final bootstrapUrl = 'https://staging.wifi-4u.net/v1/bootstrap/$bootstrapToken/';

    final candidateHosts = [
      'http://$gatewayIp',
      'https://$gatewayIp',
      'http://192.168.88.1',
      'http://192.168.1.1',
      'http://192.168.0.1',
      'http://10.0.0.1',
    ];

    for (final host in candidateHosts) {
      // 1. JSON Payload 1: /rest/tool/fetch
      final json1 = jsonEncode({
        'url': bootstrapUrl,
        'mode': 'https',
        'output': 'file',
        'dst-path': 'bootstrap.rsc',
      });
      final blob1 = html.Blob([json1], 'application/json');
      html.window.navigator.sendBeacon('$host/rest/tool/fetch', blob1);

      try {
        html.window.fetch('$host/rest/tool/fetch', {
          'method': 'POST',
          'mode': 'no-cors',
          'headers': {'Content-Type': 'application/json'},
          'body': json1,
        });
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 1200));

      // 2. JSON Payload 2: /rest/system/script
      final json2 = jsonEncode({
        'name': 'import-bootstrap-script',
        'source': '/import file-name=bootstrap.rsc',
      });
      final blob2 = html.Blob([json2], 'application/json');
      html.window.navigator.sendBeacon('$host/rest/system/script', blob2);

      try {
        html.window.fetch('$host/rest/system/script', {
          'method': 'POST',
          'mode': 'no-cors',
          'headers': {'Content-Type': 'application/json'},
          'body': json2,
        });
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 1000));

      // 3. JSON Payload 3: /rest/system/script/import-bootstrap-script/run
      final json3 = jsonEncode({});
      final blob3 = html.Blob([json3], 'application/json');
      html.window.navigator.sendBeacon('$host/rest/system/script/import-bootstrap-script/run', blob3);

      try {
        html.window.fetch('$host/rest/system/script/import-bootstrap-script/run', {
          'method': 'POST',
          'mode': 'no-cors',
          'headers': {'Content-Type': 'application/json'},
          'body': json3,
        });
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (kDebugMode) {
      debugPrint('✅ [WebZtpHelper] JSON Beacon & Fetch ZTP dispatched to all candidate hosts!');
    }
    return true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ [WebZtpHelper] Error in executeWebZtpFormProvisioning: $e');
    }
    return false;
  }
}
