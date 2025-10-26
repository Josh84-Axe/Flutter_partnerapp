import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hotspot_partner_app/main.dart';
import 'package:hotspot_partner_app/providers/app_state.dart';
import 'package:hotspot_partner_app/providers/theme_provider.dart';

void main() {
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
    
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
