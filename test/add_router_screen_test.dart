import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hotspot_partner_app/screens/add_router_screen.dart';
import 'package:hotspot_partner_app/providers/split/network_provider.dart';

class MockNetworkProvider extends ChangeNotifier implements NetworkProvider {
  @override
  bool get isLoading => false;

  @override
  Future<Map<String, dynamic>?> addRouter(Map<String, dynamic> routerData) async {
    return {
      'id': 42,
      'name': 'TestWifi',
      'status': 'pending',
      'is_active': false,
      'ip_address': '10.0.0.8',
      'dns_name': 'testwifi.tiknet.net',
      'username': 'tiknet-admin',
      'partner': 'admin',
      'bootstrap_command': '/tool fetch url="https://api.tiknetafrica.com/v1/bootstrap/abc123/" mode=https output=file dst-path=bootstrap.rsc\n/import file-name=bootstrap.rsc',
      'login_page_command': "/tool fetch url='https://api.tiknetafrica.com/v1/mikrotik/login-page/' mode=https output=file dst-path=flash/hotspot/login.html",
      'setup_command': '/ip dhcp-client add interface=ether1\n/ip dns set allow-remote-requests=yes'
    };
  }

  // Implement required NetworkProvider methods as no-ops to satisfy the interface
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

    // Verify the three command sections are visible
    expect(find.text('Commande Bootstrap'), findsOneWidget);
    expect(find.text('Commande Login Page'), findsOneWidget);
    expect(find.text('Commande Setup'), findsOneWidget);
    expect(find.text('Informations Générales'), findsOneWidget);
  });
}
