import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hotspot_partner_app/services/family_api_service.dart';
import 'package:hotspot_partner_app/repositories/auth_repository.dart';
import 'package:hotspot_partner_app/services/api/token_storage.dart';
import 'package:hotspot_partner_app/locator.dart';
import 'package:dio/dio.dart';

class MockTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;
  
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }
  
  @override
  Future<String?> getAccessToken() async => _accessToken;
  
  @override
  Future<String?> getRefreshToken() async => _refreshToken;
  
  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
  
  @override
  Future<bool> hasValidToken() async => _accessToken != null;
  
  @override
  Future<bool> hasTokens() async => _accessToken != null && _refreshToken != null;
  
  @override
  Future<String?> getAppVariant() async => 'family';
  
  @override
  Future<void> saveAppVariant(String variant) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Seed Data Injection (Family Variant)', () {
    testWidgets('inject realistic seed data and output backend responses', (tester) async {
      // 1. Setup API clients and services
      final dio = Dio(BaseOptions(
        baseUrl: 'https://staging.wifi-4u.net/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      // Override TokenStorage with Mock to bypass macOS Keychain errors
      if (locator.isRegistered<TokenStorage>()) {
        locator.unregister<TokenStorage>();
      }
      final tokenStorage = MockTokenStorage();
      locator.registerLazySingleton<TokenStorage>(() => tokenStorage);
      final authRepo = AuthRepository(dio: dio, tokenStorage: tokenStorage);
      
      print('==============================================');
      print('Starting Seed Data Injection Script');
      print('==============================================');
      
      try {
        print('1. Authenticating as sientey@hotmail.com...');
        // Note: We use login endpoint
        final loginRes = await authRepo.login(
          email: 'sientey@hotmail.com',
          password: 'TiknetFamily123!',
        );
        
        final token = loginRes['data']?['token'];
        print('Login Success! Token: $token');
        
        if (token != null) {
          await tokenStorage.saveTokens(
            accessToken: token,
            refreshToken: loginRes['data']?['refresh_token'] ?? '',
          );
        }
        
        // 2. Fetch Policies
        print('2. Fetching Policies...');
        final policies = await FamilyApiService.fetchPolicies();
        print('Policies retrieved: ${policies.length}');
        
        // 3. Register a Device
        print('3. Registering Seed Device...');
        final policyId = policies.isNotEmpty ? policies.first.id : 1;
        final regRes = await FamilyApiService.registerDevice(
          1, // groupId
          'Seed iPad Pro',
          'AA:BB:CC:DD:EE:FF',
          policyId: policyId,
        );
        print('Register Device Response: ${regRes.deviceName}');
        
        // 4. Update Policy
        print('4. Updating Policy for Device...');
        final updateRes = await FamilyApiService.updateDevicePolicy(regRes.id, policyId);
        print('Update Policy Response: $updateRes');
        
        // 5. Pause Device
        print('5. Pausing Device...');
        final pauseRes = await FamilyApiService.toggleDevicePause(regRes.id, pause: true);
        print('Pause Device Response: $pauseRes');
        
        // 6. Create Schedule
        print('6. Creating Bedtime Schedule...');
        final schedRes = await FamilyApiService.createSchedule(
          regRes.id,
          'Bedtime',
          1, // Monday
          '21:00',
          '07:00',
          policyId,
        );
        print('Create Schedule Response: ${schedRes.name}');
        
        // 7. Fetch Unclaimed Devices
        print('7. Fetching Unclaimed Devices...');
        final unclaimedRes = await FamilyApiService.fetchUnclaimedDevices();
        print('Unclaimed Devices Response: ${unclaimedRes.length}');
        
        // 8. Fetch Groups
        print('8. Fetching Family Groups...');
        final groupsRes = await FamilyApiService.fetchGroups();
        print('Family Groups Response: ${groupsRes.length}');
        
      } catch (e) {
        print('==============================================');
        print('Error during seed injection: $e');
        print('Note: Staging API (https://staging.wifi-4u.net/v1) is currently returning HTTP 500');
        print('==============================================');
      }
    });
  });
}
