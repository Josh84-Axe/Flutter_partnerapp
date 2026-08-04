import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// ignore: avoid_relative_lib_imports
import 'package:hotspot_partner_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture screenshots of all bottom tabs', (WidgetTester tester) async {
    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // Onboarding Flow Handling
    
    // 0. Wait for Splash Screen to complete (1.6s delay in app)
    print('Waiting for Splash Screen...');
    await tester.pumpAndSettle(const Duration(seconds: 3));
    
    // 1. Check if we are on Onboarding Screen (New M3 version)
    // It has "User Management" text and "Log In" / "Get Started" buttons
    bool onOnboarding = find.text('User Management').evaluate().isNotEmpty;
    
    if (onOnboarding) {
      print('On Onboarding Screen. Tapping Log In...');
      // In the new OnboardingScreen, "Log In" button calls _completeOnboarding -> /login
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else {
      print('Not on Onboarding Screen. Checking if already on Login...');
    }

    // 2. Login Screen check
    // Look for "Tiknet Partner" title or unique elements of LoginScreenM3
    bool onLogin = find.text('Tiknet Partner').evaluate().isNotEmpty;
    
    if (!onLogin) {
       // Maybe we are on the old login screen or somewhere else?
       // Just print current state for debug
       print('Warning: "Tiknet Partner" text not found. Trying to find Email field anyway.');
    }

    print('Attempting to fill login form...');
    
    // Use Key if possible, or robust text finders
    final emailFinder = find.widgetWithText(TextFormField, 'Email');
    final passwordFinder = find.widgetWithText(TextFormField, 'Password');
    final loginButtonFinder = find.widgetWithText(FilledButton, 'Login');

    if (emailFinder.evaluate().isNotEmpty) {
      await tester.enterText(emailFinder, 'americanhouse@gmail.com');
      await tester.pumpAndSettle();
      
      await tester.enterText(passwordFinder, 'Testing987');
      await tester.pumpAndSettle();
      
      await tester.tap(loginButtonFinder);
      print('Login button tapped. Waiting for navigation...');
      
      // Initial wait for network request
      await tester.pump(const Duration(seconds: 2));
      // Wait for navigation animations
      await tester.pumpAndSettle(const Duration(seconds: 8));
    } else {
      print('Login form fields not found!');
    }

    // Wait for Home Screen (look for Dashboard icon)
    // Try multiple pumps if needed
    if (find.byIcon(Icons.dashboard).evaluate().isEmpty) {
      print('Dashboard not found immediately. Waiting more...');
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
    
    // Debug: Print tree if Dashboard still not found
    if (find.byIcon(Icons.dashboard).evaluate().isEmpty) {
       debugDumpApp();
    }

    expect(find.byIcon(Icons.dashboard), findsOneWidget);
    
    // Helper to tap bottom nav
    Future<void> tapTab(IconData icon, String label) async {
       // Find the icon SPECIFICALLY inside the NavigationBar to avoid matches in the dashboard body
       final tabFinder = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(icon),
       );
       
       // Fallback to text if icon is still ambiguous or not found (though icon is safer for l10n if we knew the l10n keys)
       // But we have the icon data.
       
       await tester.tap(tabFinder);
       await tester.pumpAndSettle();
       await tester.pump(const Duration(seconds: 2)); // Wait for page load
    }

    // 1. Dashboard
    // Already there, but let's take screenshot
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01_dashboard');

    // 2. Users Tab
    print('Tapping Users tab...');
    await tapTab(Icons.people, 'Users');
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02_users');

    // 3. Plans Tab
    print('Tapping Plans tab...');
    await tapTab(Icons.wifi, 'Plans');
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('03_plans');

    // 4. Wallet Tab
    print('Tapping Wallet tab...');
    await tapTab(Icons.account_balance_wallet, 'Wallet');
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04_wallet');
    print('Screenshot taken: 04_wallet');
  });
}
