import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

Future<bool> executeWebZtpFormProvisioning({
  required String gatewayIp,
  required String bootstrapToken,
  required String routerName,
}) async {
  try {
    if (kDebugMode) {
      debugPrint('⚡ [WebZtpHelper] Executing dual-vector automatic ZTP to $gatewayIp...');
    }

    final bootstrapUrl = 'https://staging.wifi-4u.net/v1/bootstrap/$bootstrapToken/';

    // Ensure target iframe exists in DOM
    html.IFrameElement? iframe = html.document.querySelector('#ztp_web_iframe') as html.IFrameElement?;
    if (iframe == null) {
      iframe = html.IFrameElement()
        ..id = 'ztp_web_iframe'
        ..name = 'ztp_web_iframe'
        ..style.display = 'none';
      html.document.body?.children.add(iframe);
    }

    final targets = [
      'http://$gatewayIp',
      'https://$gatewayIp',
    ];

    for (final targetHost in targets) {
      // Step 1: Form POST to /rest/tool/fetch
      final form1 = html.FormElement()
        ..action = '$targetHost/rest/tool/fetch'
        ..method = 'POST'
        ..target = 'ztp_web_iframe'
        ..style.display = 'none';

      form1.children.add(html.InputElement()..name = 'url'..value = bootstrapUrl);
      form1.children.add(html.InputElement()..name = 'mode'..value = 'https');
      form1.children.add(html.InputElement()..name = 'output'..value = 'file');
      form1.children.add(html.InputElement()..name = 'dst-path'..value = 'bootstrap.rsc');

      html.document.body?.children.add(form1);
      form1.submit();
      await Future.delayed(const Duration(milliseconds: 800));
      form1.remove();

      // Step 2: Form POST to /rest/system/script
      final form2 = html.FormElement()
        ..action = '$targetHost/rest/system/script'
        ..method = 'POST'
        ..target = 'ztp_web_iframe'
        ..style.display = 'none';

      form2.children.add(html.InputElement()..name = 'name'..value = 'import-bootstrap-script');
      form2.children.add(html.InputElement()..name = 'source'..value = '/import file-name=bootstrap.rsc');

      html.document.body?.children.add(form2);
      form2.submit();
      await Future.delayed(const Duration(milliseconds: 800));
      form2.remove();

      // Step 3: Form POST to /rest/system/script/import-bootstrap-script/run
      final form3 = html.FormElement()
        ..action = '$targetHost/rest/system/script/import-bootstrap-script/run'
        ..method = 'POST'
        ..target = 'ztp_web_iframe'
        ..style.display = 'none';

      html.document.body?.children.add(form3);
      form3.submit();
      await Future.delayed(const Duration(milliseconds: 800));
      form3.remove();
    }

    if (kDebugMode) {
      debugPrint('✅ [WebZtpHelper] Dual-vector automatic ZTP dispatched cleanly!');
    }
    return true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ [WebZtpHelper] Error in executeWebZtpFormProvisioning: $e');
    }
    return false;
  }
}
