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
      debugPrint('⚡ [WebZtpHelper] Dispatching automatic form-target ZTP to $gatewayIp...');
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

    // Step 1: Form POST to /rest/tool/fetch
    final form1 = html.FormElement()
      ..action = 'http://$gatewayIp/rest/tool/fetch'
      ..method = 'POST'
      ..target = 'ztp_web_iframe'
      ..style.display = 'none';

    form1.children.add(html.InputElement()..name = 'url'..value = bootstrapUrl);
    form1.children.add(html.InputElement()..name = 'mode'..value = 'https');
    form1.children.add(html.InputElement()..name = 'output'..value = 'file');
    form1.children.add(html.InputElement()..name = 'dst-path'..value = 'bootstrap.rsc');

    html.document.body?.children.add(form1);
    form1.submit();
    await Future.delayed(const Duration(milliseconds: 1500));
    form1.remove();

    // Step 2: Form POST to /rest/system/script
    final form2 = html.FormElement()
      ..action = 'http://$gatewayIp/rest/system/script'
      ..method = 'POST'
      ..target = 'ztp_web_iframe'
      ..style.display = 'none';

    form2.children.add(html.InputElement()..name = 'name'..value = 'import-bootstrap-script');
    form2.children.add(html.InputElement()..name = 'source'..value = '/import file-name=bootstrap.rsc');

    html.document.body?.children.add(form2);
    form2.submit();
    await Future.delayed(const Duration(milliseconds: 1000));
    form2.remove();

    // Step 3: Form POST to /rest/system/script/import-bootstrap-script/run
    final form3 = html.FormElement()
      ..action = 'http://$gatewayIp/rest/system/script/import-bootstrap-script/run'
      ..method = 'POST'
      ..target = 'ztp_web_iframe'
      ..style.display = 'none';

    html.document.body?.children.add(form3);
    form3.submit();
    await Future.delayed(const Duration(milliseconds: 1000));
    form3.remove();

    if (kDebugMode) {
      debugPrint('✅ [WebZtpHelper] Automatic Web ZTP Dispatched cleanly!');
    }
    return true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ [WebZtpHelper] Error in executeWebZtpFormProvisioning: $e');
    }
    return false;
  }
}
