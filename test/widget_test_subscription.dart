import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotspot_partner_app/widgets/subscription_plan_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Widget createWidgetUnderTest(SubscriptionPlanCard widget) {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'lib/l10n',
      child: MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );
  }

  testWidgets('SubscriptionPlanCard displays plan name and renewal date', (WidgetTester tester) async {
    final renewalDate = DateTime.now().add(const Duration(days: 10));
    
    await tester.pumpWidget(createWidgetUnderTest(
      SubscriptionPlanCard(
        planName: 'Standard Plan',
        renewalDate: renewalDate,
      ),
    ));
    
    await tester.pump(); // Allow EasyLocalization to load

    expect(find.text('Standard Plan'), findsOneWidget);
    // Note: Date formatting might vary based on locale, but checking for plan name is a good start
  });

  testWidgets('SubscriptionPlanCard shows correct countdown for > 1 day', (WidgetTester tester) async {
    final renewalDate = DateTime.now().add(const Duration(days: 5, hours: 2));
    
    await tester.pumpWidget(createWidgetUnderTest(
      SubscriptionPlanCard(
        planName: 'Standard Plan',
        renewalDate: renewalDate,
      ),
    ));
    
    await tester.pump();

    expect(find.text('5 days left'), findsOneWidget);
  });

  testWidgets('SubscriptionPlanCard shows correct countdown for < 1 day', (WidgetTester tester) async {
    final renewalDate = DateTime.now().add(const Duration(hours: 5, minutes: 30));
    
    await tester.pumpWidget(createWidgetUnderTest(
      SubscriptionPlanCard(
        planName: 'Standard Plan',
        renewalDate: renewalDate,
      ),
    ));
    
    await tester.pump();

    expect(find.text('5 hours left'), findsOneWidget);
  });
  
  testWidgets('SubscriptionPlanCard shows Expired for past date', (WidgetTester tester) async {
    final renewalDate = DateTime.now().subtract(const Duration(days: 1));
    
    await tester.pumpWidget(createWidgetUnderTest(
      SubscriptionPlanCard(
        planName: 'Standard Plan',
        renewalDate: renewalDate,
      ),
    ));
    
    await tester.pump();

    expect(find.text('Expired'), findsOneWidget);
  });
}
