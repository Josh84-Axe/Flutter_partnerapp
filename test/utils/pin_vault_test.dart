import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hotspot_partner_app/services/api/pin_vault.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('isPinConfigured returns false initially', () async {
    final isConfigured = await PinVault.isPinConfigured();
    expect(isConfigured, isFalse);
  });

  test('saveCredentials saves successfully and isPinConfigured returns true', () async {
    await PinVault.saveCredentials('test@example.com', 'password123', '123456');
    final isConfigured = await PinVault.isPinConfigured();
    expect(isConfigured, isTrue);
  });

  test('getCredentialsWithPin returns correct credentials with valid PIN', () async {
    await PinVault.saveCredentials('test@example.com', 'password123', '123456');
    final creds = await PinVault.getCredentialsWithPin('123456');
    
    expect(creds, isNotNull);
    expect(creds!['email'], 'test@example.com');
    expect(creds['password'], 'password123');
  });

  test('getCredentialsWithPin returns null with invalid PIN', () async {
    await PinVault.saveCredentials('test@example.com', 'password123', '123456');
    final creds = await PinVault.getCredentialsWithPin('654321');
    
    expect(creds, isNull);
  });

  test('clearVault removes the vault successfully', () async {
    await PinVault.saveCredentials('test@example.com', 'password123', '123456');
    expect(await PinVault.isPinConfigured(), isTrue);
    
    await PinVault.clearVault();
    expect(await PinVault.isPinConfigured(), isFalse);
  });
}
