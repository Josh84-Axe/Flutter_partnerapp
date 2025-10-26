import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotspot_partner_app/main.dart';
import 'package:hotspot_partner_app/providers/app_state.dart';
import 'package:hotspot_partner_app/providers/theme_provider.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock SharedPreferences to avoid platform channel calls
    SharedPreferences.setMockInitialValues({});
    
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
  });

  testWidgets('App builds successfully', (WidgetTester tester) async {
    await EasyLocalization.ensureInitialized();
    
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
    await tester.pump();
    
    // Verify MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
