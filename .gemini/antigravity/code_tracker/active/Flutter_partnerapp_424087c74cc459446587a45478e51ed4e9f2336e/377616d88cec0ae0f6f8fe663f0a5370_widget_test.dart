õimport 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotspot_partner_app/main.dart';
import 'package:hotspot_partner_app/providers/app_state.dart';
import 'package:hotspot_partner_app/providers/theme_provider.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock Google Fonts to use default fonts in tests
    GoogleFonts.config.allowRuntimeFetching = false;
    
    // Set fallback font family to prevent font loading errors
    const fallbackFontFamily = 'Roboto';
    
    // Mock SharedPreferences to avoid platform channel calls
    // Set onboarding_completed to true to skip splash/onboarding flow in tests
    SharedPreferences.setMockInitialValues({
      'onboarding_completed': true,
    });
    
    // Mock SharedPreferences to avoid platform channel calls
    // Set onboarding_completed to true to skip splash/onboarding flow in tests
    SharedPreferences.setMockInitialValues({
      'onboarding_completed': true,
    });
    
    // Mock dynamic_color plugin to return null (no dynamic colors in tests)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dynamic_color'),
      (MethodCall call) async {
        if (call.method == 'getCorePalette') {
          return null; // No dynamic colors available in test environment
        }
        return null;
      },
    );

    // Mock flutter_secure_storage
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  testWidgets('App builds successfully', (WidgetTester tester) async {
    await EasyLocalization.ensureInitialized();
    
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('fr')],
          path: 'lib/l10n',
          fallbackLocale: const Locale('en'),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AppState()),
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ],
            child: const HotspotPartnerApp(),
          ),
        ),
      );
      
      // Use pump() instead of pumpAndSettle() to avoid infinite wait
      // The app will show SplashScreen initially
      await tester.pump();
      
      // Verify MaterialApp is present
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Wait for the splash screen timer to complete (1.6s)
      await Future.delayed(const Duration(milliseconds: 1700));
      await tester.pump();
    });
  });
}
í íÏ*cascade08
Ïõ "(424087c74cc459446587a45478e51ed4e9f2336e2^file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/test/widget_test.dart:Hfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp