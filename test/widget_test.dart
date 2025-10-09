import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotspot_partner_app/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const HotspotPartnerApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
