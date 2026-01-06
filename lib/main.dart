import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

// Providers
import 'providers/split/auth_provider.dart';
import 'providers/split/billing_provider.dart';
import 'providers/split/user_provider.dart';
import 'providers/split/network_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/tiknet_themes.dart';

// Services
import 'services/api/api_client_factory.dart';
import 'services/api/token_storage.dart';
import 'services/api/api_config.dart';

// Repositories
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

// Screens
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/settings_screen.dart';
import 'feature/launch/splash_screen.dart';
import 'feature/launch/onboarding_screen.dart';
import 'feature/auth/login_screen_m3.dart';
import 'screens/notifications_screen.dart';
import 'screens/language_screen.dart';
import 'feature/auth/forgot_password_screen.dart';
import 'feature/auth/verify_password_reset_otp_screen.dart';
import 'screens/email_verification_screen.dart';
import 'feature/auth/reset_password_screen.dart';

import 'screens/reset_email_sent_screen.dart';
import 'screens/set_new_password_screen.dart';
import 'screens/password_success_screen.dart';
import 'screens/profiles_screen.dart';
import 'screens/router_details_screen.dart';

import 'screens/bulk_actions_screen.dart';
import 'models/hotspot_profile_model.dart';
import 'models/user_model.dart';

import 'screens/hotspot_user_screen.dart';
import 'screens/configurations_screen.dart';
import 'screens/router_registration_screen.dart';
import 'screens/config/rate_limit_config_screen.dart';
import 'screens/config/idle_time_config_screen.dart';
import 'screens/config/plan_validity_config_screen.dart';
import 'screens/config/data_limit_config_screen.dart';
import 'screens/config/shared_user_config_screen.dart';
import 'screens/config/additional_device_config_screen.dart';

import 'screens/internet_plans_settings_screen.dart';
import 'screens/subscription_management_screen.dart';
import 'screens/router_settings_screen.dart';
import 'screens/add_router_screen.dart';

import 'screens/create_edit_plan_screen.dart';
import 'screens/assign_user_screen.dart';
import 'screens/create_role_screen.dart';
import 'screens/worker_profile_setup_screen.dart';
import 'screens/worker_activation_screen.dart';
import 'screens/router_assign_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/about_app_screen.dart';
import 'screens/empty_state_screen.dart';
import 'screens/wallet_overview_screen.dart';
import 'screens/payout_request_screen.dart';
import 'screens/payout_submitted_screen.dart';
import 'screens/revenue_breakdown_screen.dart';
import 'screens/security/password_and_2fa_screen.dart';
import 'screens/security/authenticators_screen.dart';
import 'screens/security/success_2fa_screen.dart';
import 'screens/partner_profile_screen.dart';
import 'screens/otp_validation_screen.dart';
import 'screens/reporting_screen.dart';
import 'screens/report_preview_screen.dart';
import 'screens/export_success_screen.dart';
import 'screens/create_edit_user_profile_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/notification_center_screen.dart';
import 'screens/notification_router_screen.dart';
import 'screens/user_details_screen.dart';
import 'screens/role_permission_screen.dart';
import 'screens/assign_role_screen.dart';
import 'screens/router_health_screen.dart';
import 'screens/transaction_payment_history_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/payout_history_screen.dart';
import 'screens/transaction_details_screen.dart';
import 'screens/add_payout_method_screen.dart';
import 'screens/assign_router_screen.dart';

import 'screens/hotspot_users_management_screen.dart';
import 'screens/plan_assignment_screen.dart';
import 'screens/session_management_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/collaborators_management_screen.dart';
import 'screens/assigned_plans_list_screen.dart';
import 'screens/active_sessions_screen.dart';
import 'screens/help_support_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Dependency Injection Setup
  final tokenStorage = TokenStorage();
  final apiClientFactory = ApiClientFactory(
    tokenStorage: tokenStorage,
    baseUrl: ApiConfig.baseUrl, 
  );
  final dio = apiClientFactory.createDio();

  // Core Repositories
  final authRepository = AuthRepository(dio: dio, tokenStorage: tokenStorage);
  final partnerRepository = PartnerRepository(dio: dio);
  
  // Feature Repositories
  final walletRepository = WalletRepository(dio: dio);
  final transactionRepository = TransactionRepository(dio: dio);
  final paymentMethodRepository = PaymentMethodRepository(dio: dio);
  
  final customerRepository = CustomerRepository(dio: dio);
  final collaboratorRepository = CollaboratorRepository(dio: dio);
  final roleRepository = RoleRepository(dio: dio);
  final subscriptionRepository = SubscriptionRepository(dio: dio);
  final planRepository = PlanRepository(dio: dio);
  
  final routerRepository = RouterRepository(dio: dio);
  final hotspotRepository = HotspotRepository(dio: dio);
  final sessionRepository = SessionRepository(dio: dio);
  final planConfigRepository = PlanConfigRepository(dio: dio);
  
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
              authRepository: authRepository,
              partnerRepository: partnerRepository,
              tokenStorage: tokenStorage,
            ),
          ),
          
          ChangeNotifierProxyProvider<AuthProvider, BillingProvider>(
            create: (_) => BillingProvider(
              walletRepository: walletRepository,
              transactionRepository: transactionRepository,
              paymentMethodRepository: paymentMethodRepository,
            ),
            update: (context, auth, prev) {
              final provider = prev ?? BillingProvider(
                walletRepository: walletRepository,
                transactionRepository: transactionRepository,
                paymentMethodRepository: paymentMethodRepository,
              );
              provider.update(
                walletRepository: walletRepository,
                transactionRepository: transactionRepository,
                paymentMethodRepository: paymentMethodRepository,
                partnerCountry: auth.partnerCountry,
              );
              return provider;
            },
          ),
          
          ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
            create: (_) => UserProvider(
              customerRepository: customerRepository,
              collaboratorRepository: collaboratorRepository,
              roleRepository: roleRepository,
              subscriptionRepository: subscriptionRepository,
              partnerRepository: partnerRepository,
              planRepository: planRepository,
            ),
            update: (context, auth, prev) {
              final provider = prev ?? UserProvider(
                customerRepository: customerRepository,
                collaboratorRepository: collaboratorRepository,
                roleRepository: roleRepository,
                subscriptionRepository: subscriptionRepository,
                partnerRepository: partnerRepository,
                planRepository: planRepository,
              );
              provider.update(
                customerRepository: customerRepository,
                collaboratorRepository: collaboratorRepository,
                roleRepository: roleRepository,
                subscriptionRepository: subscriptionRepository,
                partnerRepository: partnerRepository,
                planRepository: planRepository,
                authProvider: auth,
              );
              return provider;
            },
          ),
          
          ChangeNotifierProxyProvider<AuthProvider, NetworkProvider>(
            create: (_) => NetworkProvider(
              routerRepository: routerRepository,
              hotspotRepository: hotspotRepository,
              sessionRepository: sessionRepository,
              customerRepository: customerRepository,
              planConfigRepository: planConfigRepository,
              planRepository: planRepository,
            ),
            update: (context, auth, prev) {
              final provider = prev ?? NetworkProvider(
                routerRepository: routerRepository,
                hotspotRepository: hotspotRepository,
                sessionRepository: sessionRepository,
                customerRepository: customerRepository,
                planConfigRepository: planConfigRepository,
                planRepository: planRepository,
              );
              provider.update(
                routerRepository: routerRepository,
                hotspotRepository: hotspotRepository,
                sessionRepository: sessionRepository,
                customerRepository: customerRepository,
                planConfigRepository: planConfigRepository,
                planRepository: planRepository,
                authProvider: auth,
              );
              return provider;
            },
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
    
    // Use ThemeProvider's selected theme directly (no dynamic colors from wallpaper)
    // This ensures consistent brand colors regardless of device wallpaper
    return MaterialApp(
      title: 'Tiknet Partner App',
      theme: themeProvider.currentTheme,
      darkTheme: TiknetThemes.getPillRoundedDarkTheme(),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth-wrapper': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreenM3(),
        '/login-old': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/language': (context) => const LanguageScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-email-sent': (context) => const ResetEmailSentScreen(),
        '/set-new-password': (context) => const SetNewPasswordScreen(),
        '/password-success': (context) => const PasswordSuccessScreen(),
        '/profiles': (context) => const ProfilesScreen(),

        '/bulk-actions': (context) => const BulkActionsScreen(),
        '/hotspot-user': (context) => const HotspotUserScreen(),
        '/configurations': (context) => const ConfigurationsScreen(),
        '/router-registration': (context) => const RouterRegistrationScreen(),
        '/config/rate-limit': (context) => const RateLimitConfigScreen(),
        '/config/idle-time': (context) => const IdleTimeConfigScreen(),
        '/config/plan-validity': (context) => const PlanValidityConfigScreen(),
        '/config/data-limit': (context) => const DataLimitConfigScreen(),
        '/config/shared-users': (context) => const SharedUserConfigScreen(),
        '/config/additional-devices': (context) => const AdditionalDeviceConfigScreen(),
        '/internet-plan': (context) => const PlansScreen(),
        '/internet-plans-settings': (context) => const InternetPlansSettingsScreen(),
        '/subscription-management': (context) => const SubscriptionManagementScreen(),
        '/router-settings': (context) => const RouterSettingsScreen(),
        '/add-router': (context) => const AddRouterScreen(),
        '/role-permissions': (context) => const RolePermissionScreen(),
        '/assign-role': (context) => const AssignRoleScreen(),
        '/worker-profile-setup': (context) => const WorkerProfileSetupScreen(),
        '/worker-activation': (context) => const WorkerActivationScreen(),
        '/wallet-overview': (context) => const WalletOverviewScreen(),
        '/payout-request': (context) => const PayoutRequestScreen(),
        '/payout-submitted': (context) => const PayoutSubmittedScreen(),
        '/revenue-breakdown': (context) => const RevenueBreakdownScreen(),
        '/router-health': (context) => const RouterHealthScreen(),
        '/transaction-payment-history': (context) => const TransactionPaymentHistoryScreen(),
        '/transaction-history': (context) => const TransactionHistoryScreen(),
        '/payout-history': (context) => const PayoutHistoryScreen(),
        '/transaction-details': (context) => const TransactionDetailsScreen(),
        '/add-payout-method': (context) => const AddPayoutMethodScreen(),
        '/assign-router': (context) => const AssignRouterScreen(),
        '/security/password-2fa': (context) => const PasswordAndTwoFactorScreen(),
        '/security/authenticators': (context) => const AuthenticatorsScreen(),
        '/security/2fa-success': (context) => const TwoFactorSuccessScreen(),
        '/partner-profile': (context) => const PartnerProfileScreen(),
        '/otp-validation': (context) => const OtpValidationScreen(),
        '/reporting': (context) => const ReportingScreen(),
        '/report-preview': (context) => const ReportPreviewScreen(),
        '/export-success': (context) => const ExportSuccessScreen(),
        '/create-edit-user-profile': (context) {
          final profile = ModalRoute.of(context)?.settings.arguments as HotspotProfileModel?;
          return CreateEditUserProfileScreen(profile: profile);
        },
        '/notification-settings': (context) => const NotificationSettingsScreen(),
        '/notification-center': (context) => const NotificationCenterScreen(),
        '/notification-router': (context) => const NotificationRouterScreen(),
        '/user-details': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as UserModel;
          return UserDetailsScreen(user: user);
        },
        '/onboarding-old': (context) => const OnboardingFlow(),
        '/about': (context) => const AboutAppScreen(),
        '/empty-state': (context) => const EmptyStateScreen(),
        '/email-verification': (context) {
          return const EmailVerificationScreen();
        },
        '/hotspot-users-management': (context) => const HotspotUsersManagementScreen(),
        '/plan-assignment': (context) => const PlanAssignmentScreen(),
        '/session-management': (context) => const SessionManagementScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/collaborators-management': (context) => const CollaboratorsManagementScreen(),
        '/assigned-plans-list': (context) => const AssignedPlansListScreen(),
        '/active-sessions': (context) => const ActiveSessionsScreen(),
        '/support': (context) => const HelpSupportScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/router-details') {
          final router = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => RouterDetailsScreen(router: router as dynamic),
          );
        }
        if (settings.name == '/profile-editor') {
          final profile = settings.arguments as HotspotProfileModel?;
          return MaterialPageRoute(
            builder: (context) => CreateEditUserProfileScreen(profile: profile),
          );
        }
        if (settings.name == '/create-edit-plan') {
          final planData = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => CreateEditPlanScreen(planData: planData),
          );
        }
        if (settings.name == '/assign-user') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AssignUserScreen(
              planId: args['planId'] as String,
              planName: args['planName'] as String,
            ),
          );
        }
        if (settings.name == '/create-role') {
          final roleData = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => CreateRoleScreen(roleData: roleData),
          );
        }
        if (settings.name == '/router-assign') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RouterAssignScreen(
              userId: args['userId'] as String,
              userName: args['userName'] as String,
            ),
          );
        }
        if (settings.name == '/verify-password-reset-otp') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => VerifyPasswordResetOtpScreen(
              email: args['email'] as String,
              otpId: args['otp_id']?.toString() ?? '',
            ),
          );
        }
        if (settings.name == '/reset-password') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: args['email'] as String,
              token: args['token'] as String,
            ),
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    // Check for new onboarding_completed flag (used by new launch flow)
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
    // Also check old flag for backward compatibility
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    
    setState(() {
      _hasSeenOnboarding = hasCompletedOnboarding || hasSeenOnboarding;
      _isLoading = false;
    });

    if (_hasSeenOnboarding) {
      if (mounted) {
        context.read<AuthProvider>().checkAuthStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasSeenOnboarding) {
      // Show new M3 onboarding
      return const OnboardingScreen();
    }

    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      // Show new M3 login screen
      return const LoginScreenM3();
    }

    final userProvider = context.watch<UserProvider>();
    
    // Trigger subscription load if not already loaded
    if (!userProvider.isSubscriptionLoaded && !userProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userProvider.loadSubscription();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Wait for subscription check completion
    if (!userProvider.isSubscriptionLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final subscription = userProvider.subscription;
    
    // Check if subscription is expired
    bool needsSubscription = subscription == null || !subscription.isActive;
    
    if (needsSubscription) {
      // Calculate grace period
      int daysSinceExpiration = 0;
      if (subscription != null) {
        daysSinceExpiration = DateTime.now().difference(subscription.renewalDate).inDays;
      } else {
        // If subscription is null, we assume it's a new user who needs to subscribe
        // Actually, if it's null, we might want to check if they have any purchased plans
        // But for simplicity, we treat null as expired with 0 days grace.
        daysSinceExpiration = 0;
      }

      bool isGracePeriod = daysSinceExpiration <= 5;
      
      if (!isGracePeriod) {
        // Persistent redirection
        return const SubscriptionManagementScreen(canDismiss: false);
      } else if (!userProvider.hasSkippedSubscriptionCheck) {
        // Grace period redirection (one-time per session prompt)
        return const SubscriptionManagementScreen(canDismiss: true);
      }
    }

    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const UsersScreen(),
    const PlansScreen(),
    const WalletOverviewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Row(
        children: [
          if (isTablet)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard),
                  label: Text('dashboard_title'.tr()),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.people),
                  label: Text('users'.tr()),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.wifi),
                  label: Text('plans'.tr()),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.account_balance_wallet),
                  label: Text('wallet'.tr()),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isTablet
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.dashboard),
                  label: 'dashboard_title'.tr(),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people),
                  label: 'users'.tr(),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.wifi),
                  label: 'plans'.tr(),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet),
                  label: 'wallet'.tr(),
                ),
              ],
            ),
      drawer: NavigationDrawer(
        onDestinationSelected: (index) {
          Navigator.pop(context);
          if (index == 0) {
            Navigator.of(context).pushNamed('/settings');
          } else if (index == 1) {
            Navigator.of(context).pushNamed('/support');
          }
        },
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.watch<AuthProvider>().currentUser?.name ?? 'Partner',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.watch<AuthProvider>().currentUser?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.settings),
            label: Text('settings'.tr()),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.help),
            label: Text('help_support'.tr()),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: Text('logout'.tr()),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
