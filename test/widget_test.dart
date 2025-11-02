import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hotspot_partner_app/main.dart';
import 'package:hotspot_partner_app/providers/app_state.dart';
import 'package:hotspot_partner_app/providers/theme_provider.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const HotspotPartnerApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
