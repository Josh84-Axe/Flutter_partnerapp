import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotspot_partner_app/repositories/auth_repository.dart';
import 'package:hotspot_partner_app/services/family_api_service.dart';
import 'package:hotspot_partner_app/services/api/api_config.dart';
import 'package:hotspot_partner_app/services/api/token_storage.dart';
import 'package:hotspot_partner_app/locator.dart';
import 'package:hotspot_partner_app/models/family_models.dart';
import 'dart:math';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const String fredEmail = String.fromEnvironment('FRED_EMAIL', defaultValue: 'fred@wifi-4u.net');
  const String fredPassword = String.fromEnvironment('FRED_PASSWORD', defaultValue: 'password123');

  setUpAll(() async {
    // Setup Locator for TokenStorage
    SharedPreferences.setMockInitialValues({});
    setupLocator();
  });

  group('Fred Account Seed Data QA', () {
    test('1. Authenticate Fred Account', () async {
      print('🔐 Authenticating as Fred ($fredEmail)...');
      
      try {
        final authRepo = locator<AuthRepository>();
        final authResponse = await authRepo.login(email: fredEmail, password: fredPassword);
        expect(authResponse['success'], true);
        print('✅ Fred authenticated successfully. JWT Acquired.');
      } catch (e) {
        print('❌ Authentication failed! Ensure you run this test with valid credentials:');
        print('flutter test test/seed_data_qa_test.dart --dart-define=FRED_EMAIL=... --dart-define=FRED_PASSWORD=...');
        fail('Authentication failed for Fred account: $e');
      }
    });

    test('2. Verify Unclaimed Network Discovery API', () async {
      print('📡 Fetching Unclaimed Devices from Router...');
      
      try {
        final devices = await FamilyApiService.fetchUnclaimedDevices();
        print('✅ Network Discovery returned ${devices.length} devices.');
        // Even if 0, it means the API responded 200 OK
        expect(devices, isA<List<UnclaimedDevice>>());
      } catch (e) {
        fail('Network Discovery API Failed: $e');
      }
    });

    test('3. Inject Seed Device (Claiming flow)', () async {
      print('🧬 Generating mock Seed Device...');
      
      final random = Random();
      final mockMac = List.generate(6, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
      final deviceName = "Fred's Seed Tablet ${random.nextInt(1000)}";
      
      print('📤 Claiming device: $deviceName [$mockMac] with Policy ID 3 (Family Safe)...');

      try {
        // We first need the group ID. Let's fetch groups
        final groups = await FamilyApiService.fetchGroups();
        expect(groups.isNotEmpty, true, reason: "Fred must have at least one family group");
        final groupId = groups.first['id'] as int;

        final newDevice = await FamilyApiService.registerDevice(
          groupId, 
          deviceName, 
          mockMac,
          policyId: 3, // Family Safe
        );
        
        expect(newDevice, isNotNull);
        expect(newDevice.deviceName, deviceName);
        expect(newDevice.macAddress.toUpperCase(), mockMac.replaceAll(':', '')); // Backend stores flat MACs
        print('✅ Device Claimed Successfully! Backend generated ID: ${newDevice.id}');
      } catch (e) {
        fail('Device Registration Failed: $e');
      }
    });

    test('4. Fetch Devices and Update Policy (Enforcement validation)', () async {
      print('🔍 Fetching all of Fred\'s claimed devices...');
      
      try {
        final devices = await FamilyApiService.fetchDevices();
        expect(devices.isNotEmpty, true);
        
        // Pick the last registered device
        final targetDevice = devices.last;
        print('⚙️ Updating Content Policy for ${targetDevice.deviceName} (ID: ${targetDevice.id}) to CIPA_STRICT (ID: 4)...');

        final success = await FamilyApiService.updateDevicePolicy(targetDevice.id, 4); // 4 = CIPA_STRICT
        expect(success, true);
        print('✅ Policy updated successfully on the backend!');
      } catch (e) {
        fail('Policy Update Failed: $e');
      }
    });

    test('5. Inject Time Schedule (Bedtime Lockout)', () async {
      print('🕒 Creating automated bedtime schedule for the seeded device...');
      
      try {
        final devices = await FamilyApiService.fetchDevices();
        expect(devices.isNotEmpty, true);
        final targetDevice = devices.last;

        final schedule = await FamilyApiService.createSchedule(
          targetDevice.id,
          "Fred's Automated Bedtime",
          0, // Monday
          "21:00",
          "06:00",
          3, // Family Safe
        );

        expect(schedule, isNotNull);
        expect(schedule.name, "Fred's Automated Bedtime");
        print('✅ Schedule successfully injected to the backend! Schedule ID: ${schedule.id}');
      } catch (e) {
        fail('Schedule Creation Failed: $e');
      }
    });
  });
}
