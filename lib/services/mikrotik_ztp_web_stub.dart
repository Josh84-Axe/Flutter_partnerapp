import 'dart:async';

Future<bool> isLocalAgentAvailable() async => false;

Future<Map<String, dynamic>> checkLocalAgentAuth({
  required String gatewayIp,
  String username = 'admin',
  String password = '',
}) async => {'success': false, 'message': 'Non supporté sur cette plateforme'};

Future<Map<String, dynamic>> executeLocalAgentProvisioning({
  required String gatewayIp,
  required String scriptSource,
  String username = 'admin',
  String password = '',
  String? newPassword,
}) async => {'success': false, 'message': 'Non supporté sur cette plateforme'};

Future<bool> executeWebZtpFormProvisioning({
  required String gatewayIp,
  required String bootstrapToken,
  required String routerName,
  String username = 'admin',
  String password = '',
}) async {
  return false;
}
