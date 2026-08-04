import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hotspot_partner_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Family E2E Test', () {
    testWidgets('Register Family Account and Navigate', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('Handling onboarding/login navigation...');
      
      // Dump text to debug what screen we are on
      final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList();
      print('DEBUG TEXTS ON SCREEN: \${texts.join(', ')}');

      // Step 1: Onboarding -> tap Get Started to go to Smart Welcome
      final getStartedFinder = find.text('Get Started');
      if (getStartedFinder.evaluate().isNotEmpty) {
        await tester.tap(getStartedFinder.first);
        await tester.pumpAndSettle();
      } else {
        // Fallback: If we are on login, tap Register
        final registerTextFinder = find.text("Don't have an account? Register");
        if (registerTextFinder.evaluate().isNotEmpty) {
          await tester.tap(registerTextFinder.first);
          await tester.pumpAndSettle();
        }
      }

      // Step 2: Smart Welcome -> select Home & Family -> Continue
      final familyFinder = find.text('Home & Family');
      if (familyFinder.evaluate().isNotEmpty) {
         await tester.tap(familyFinder.first);
         await tester.pumpAndSettle();
         
         // Tap continue (the only FilledButton that is enabled)
         await tester.tap(find.byType(FilledButton).first);
         await tester.pumpAndSettle();
      }

      print('Filling Registration Form...');
      // Ensure we have TextFormFields
      expect(find.byType(TextFormField), findsWidgets);
      
      await tester.enterText(find.byType(TextFormField).at(0), 'E2E Family UI');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '97045155');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(2), 'sientey+familyui@hotmail.com');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(3), 'Lome');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(4), 'TiknetFamily123!');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(5), 'TiknetFamily123!');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      print('Submitting Registration...');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 5)); 

      print('Waiting for OTP in otp.txt...');
      final otpFile = File('otp.txt');
      if (otpFile.existsSync()) {
        otpFile.deleteSync(); 
      }

      int waitTime = 0;
      while (!otpFile.existsSync() || otpFile.readAsStringSync().trim().length < 4) {
        if (waitTime > 120) {
          fail('Timed out waiting for OTP');
        }
        await Future.delayed(const Duration(seconds: 2));
        waitTime += 2;
        await tester.pump(); // Keep alive
      }

      final otpCode = otpFile.readAsStringSync().trim();
      print('Received OTP from file: \$otpCode');

      await tester.enterText(find.byType(TextFormField).first, otpCode);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      print('Verifying dashboard loaded...');
      expect(find.text('Active Devices'), findsWidgets);
      
      print('E2E Test completed successfully!');
    });
  });
}
