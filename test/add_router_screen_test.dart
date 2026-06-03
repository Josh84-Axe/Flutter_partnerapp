import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hotspot_partner_app/screens/add_router_screen.dart';
import 'package:hotspot_partner_app/providers/split/network_provider.dart';

class MockNetworkProvider extends ChangeNotifier implements NetworkProvider {
  @override
  bool get isLoading => false;

  @override
  Future<Map<String, dynamic>?> addRouter(Map<String, dynamic> routerData) async {
    return {
      "commands": [
        "/ip hotspot add name=dummy",
        "/ip pool add name=dummy_pool"
      ],
      "status": "success"
    };
  }

  // Implement required NetworkProvider methods as no-ops to satisfy the interface
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('AddRouterScreen shows server response on success', (WidgetTester tester) async {
    final mockProvider = MockNetworkProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<NetworkProvider>.value(value: mockProvider),
          ],
          child: const AddRouterScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byType(TextFormField).at(0), 'TestWifi');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
    await tester.pump();

    // Tap save
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Wait for animations

    // Verify UI provision for server response
    expect(find.textContaining('Routeur : TestWifi'), findsOneWidget);
    expect(find.text('Informations Générales'), findsOneWidget);
    expect(find.text('Commande Bootstrap'), findsOneWidget);
    
    // Verify specific commands are joined and displayed
    expect(find.textContaining('/ip hotspot add name=dummy\n/ip pool add name=dummy_pool'), findsOneWidget);
  });
}
