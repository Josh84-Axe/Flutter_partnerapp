import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hotspot_partner_app/main.dart' as app;
import 'package:hotspot_partner_app/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hotspot_partner_app/screens/family_dashboard_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Family Features E2E Test', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Ensure fresh state
      await prefs.setString('family_pin', '1234'); // Mock PIN to skip SetupPinScreen
      FlutterSecureStorage.setMockInitialValues({}); // Fix macOS keychain issues in tests
    });

    testWidgets('Login and Test Family Features', (tester) async {

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      print('Handling onboarding/login navigation...');
      
      // Force navigation to LoginScreen
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Selecting Family Variant...');
      await tester.tap(find.text('Family').last);
      await tester.pumpAndSettle();

      print('Entering Login Credentials...');
      // Looking for Email field (TextFormField index 0)
      expect(find.byType(TextFormField), findsWidgets);
      
      await tester.enterText(find.byType(TextFormField).at(0), 'sbh84@hotmail.com');
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(1), 'TiknetFamily123!');
      await tester.pumpAndSettle();

      print('Tapping Login...');
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle(const Duration(seconds: 8));

      print('Verifying Family Dashboard is loaded...');
      expect(find.byType(FamilyDashboardScreen), findsOneWidget);

      print('Testing Feature: Add Device');
      // Look for the '+' icon or Add Device button
      final addDeviceBtn = find.byIcon(Icons.add);
      if (addDeviceBtn.evaluate().isNotEmpty) {
        await tester.tap(addDeviceBtn.first);
        await tester.pumpAndSettle();
        
        print('Filling out Add Device form...');
        // First field is Device Name
        await tester.enterText(find.byType(TextFormField).first, 'Kid\'s iPad');
        await tester.pumpAndSettle();
        
        // Second field is MAC Address
        await tester.enterText(find.byType(TextFormField).last, '00:11:22:33:44:55');
        await tester.pumpAndSettle();
        
        // Tap Save
        final saveFinder = find.text('Save');
        if (saveFinder.evaluate().isNotEmpty) {
           await tester.tap(saveFinder.last);
        } else {
           await tester.tap(find.text('Add Device').last);
        }
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        // Should be back to dashboard
        expect(find.byType(FamilyDashboardScreen), findsOneWidget);
      }

      print('Testing Feature: Pause All Devices');
      // Depending on the UI, look for the 'Pause All' button or switch
      final pauseFinder = find.text('Pause All');
      if (pauseFinder.evaluate().isNotEmpty) {
        await tester.tap(pauseFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      print('Family Features Test Completed Successfully!');
    });
  });
}
