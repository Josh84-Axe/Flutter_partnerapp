import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Routes & Locator
import 'app_routes.dart';
import 'locator.dart';

// Providers
import 'providers/split/auth_provider.dart';
import 'providers/split/billing_provider.dart';
import 'providers/split/user_provider.dart';
import 'providers/split/network_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/voucher_provider.dart';
import 'theme/tiknet_themes.dart';

// Services & Repositories
import 'services/pwa_service.dart';
import 'services/api/token_storage.dart';
import 'repositories/auth_repository.dart';
import 'repositories/wallet_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/payment_method_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/collaborator_repository.dart';
import 'repositories/role_repository.dart';
import 'repositories/partner_repository.dart';
import 'repositories/plan_repository.dart';
import 'repositories/router_repository.dart';
import 'repositories/hotspot_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/plan_config_repository.dart';
import 'repositories/subscription_repository.dart';
import 'repositories/ticket_repository.dart';
import 'repositories/voucher_repository.dart';

// Initial Screens
import 'feature/launch/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Initialize Service Locator
  await setupLocator();

  const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: 'https://37bff452b01af4d6e285f9d3c913e779@o4510974779588608.ingest.de.sentry.io/4510974786469968',
  );

  if (sentryDsn.isNotEmpty && !kDebugMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
      },
      appRunner: () => _runApp(),
    );
  } else {
    _runApp();
  }
}

void _runApp() {
  try {
    locator<PwaService>().init();
  } catch (e) {
    if (kDebugMode) print('❌ [Main] PWA Service Error: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'lib/l10n',
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(
              authRepository: locator<AuthRepository>(),
              partnerRepository: locator<PartnerRepository>(),
              tokenStorage: locator<TokenStorage>(),
            ),
          ),
          ChangeNotifierProxyProvider<AuthProvider, BillingProvider>(
            create: (_) => BillingProvider(
              walletRepository: locator<WalletRepository>(),
              transactionRepository: locator<TransactionRepository>(),
              paymentMethodRepository: locator<PaymentMethodRepository>(),
            ),
            update: (context, auth, prev) {
              final provider = prev ?? BillingProvider(
                walletRepository: locator<WalletRepository>(),
                transactionRepository: locator<TransactionRepository>(),
                paymentMethodRepository: locator<PaymentMethodRepository>(),
              );
              provider.update(
                walletRepository: locator<WalletRepository>(),
                transactionRepository: locator<TransactionRepository>(),
                paymentMethodRepository: locator<PaymentMethodRepository>(),
                partnerCountry: auth.partnerCountry,
              );
              return provider;
            },
          ),
          ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
            create: (_) => UserProvider(
              customerRepository: locator<CustomerRepository>(),
              collaboratorRepository: locator<CollaboratorRepository>(),
              roleRepository: locator<RoleRepository>(),
              subscriptionRepository: locator<SubscriptionRepository>(),
              planRepository: locator<PlanRepository>(),
            ),
            update: (context, auth, prev) {
              final provider = prev ?? UserProvider(
                customerRepository: locator<CustomerRepository>(),
                collaboratorRepository: locator<CollaboratorRepository>(),
                roleRepository: locator<RoleRepository>(),
                subscriptionRepository: locator<SubscriptionRepository>(),
                planRepository: locator<PlanRepository>(),
              );
              provider.update(
                customerRepository: locator<CustomerRepository>(),
                collaboratorRepository: locator<CollaboratorRepository>(),
                roleRepository: locator<RoleRepository>(),
                subscriptionRepository: locator<SubscriptionRepository>(),
                planRepository: locator<PlanRepository>(),
                authProvider: auth,
              );
              return provider;
            },
          ),
          ChangeNotifierProxyProvider<AuthProvider, NetworkProvider>(
            create: (_) => NetworkProvider(
              routerRepository: locator<RouterRepository>(),
              hotspotRepository: locator<HotspotRepository>(),
              sessionRepository: locator<SessionRepository>(),
              customerRepository: locator<CustomerRepository>(),
              planConfigRepository: locator<PlanConfigRepository>(),
              planRepository: locator<PlanRepository>(),
            ),
            update: (context, auth, prev) {
              final provider = prev ?? NetworkProvider(
                routerRepository: locator<RouterRepository>(),
                hotspotRepository: locator<HotspotRepository>(),
                sessionRepository: locator<SessionRepository>(),
                customerRepository: locator<CustomerRepository>(),
                planConfigRepository: locator<PlanConfigRepository>(),
                planRepository: locator<PlanRepository>(),
              );
              provider.update(
                routerRepository: locator<RouterRepository>(),
                hotspotRepository: locator<HotspotRepository>(),
                sessionRepository: locator<SessionRepository>(),
                customerRepository: locator<CustomerRepository>(),
                planConfigRepository: locator<PlanConfigRepository>(),
                planRepository: locator<PlanRepository>(),
                authProvider: auth,
              );
              return provider;
            },
          ),
          ChangeNotifierProvider(
            create: (_) => TicketProvider(ticketRepository: locator<TicketRepository>()),
          ),
          ChangeNotifierProvider(
            create: (_) => VoucherProvider(repository: locator<VoucherRepository>()),
          ),
        ],
        child: const HotspotPartnerApp(),
      ),
    ),
  );
}

class HotspotPartnerApp extends StatelessWidget {
  const HotspotPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      title: 'Tiknet Partner App',
      theme: themeProvider.currentTheme,
      darkTheme: TiknetThemes.getPillRoundedDarkTheme(),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
