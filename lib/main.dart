import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/app_theme.dart';
import 'providers/app_state.dart';
import 'providers/theme_provider.dart';
import 'localization/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/health_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/language_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_email_sent_screen.dart';
import 'screens/set_new_password_screen.dart';
import 'screens/password_success_screen.dart';
import 'screens/profiles_screen.dart';
import 'screens/router_details_screen.dart';
import 'screens/support_screen.dart';
import 'screens/bulk_actions_screen.dart';
import 'screens/hotspot_user_screen.dart';
import 'screens/configurations_screen.dart';
import 'screens/router_registration_screen.dart';
import 'screens/config/rate_limit_config_screen.dart';
import 'screens/config/idle_time_config_screen.dart';
import 'screens/config/plan_validity_config_screen.dart';
import 'screens/config/data_limit_config_screen.dart';
import 'screens/config/shared_user_config_screen.dart';
import 'screens/config/additional_device_config_screen.dart';
import 'screens/internet_plan_screen.dart';
import 'screens/subscription_management_screen.dart';
import 'screens/router_settings_screen.dart';
import 'screens/add_router_screen.dart';
import 'screens/create_edit_internet_plan_screen.dart';
import 'screens/assign_user_screen.dart';
import 'screens/user_role_screen.dart';
import 'screens/create_role_screen.dart';
import 'screens/worker_profile_setup_screen.dart';
import 'screens/worker_activation_screen.dart';
import 'screens/router_assign_screen.dart';
import 'screens/revenue_breakdown_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const HotspotPartnerApp(),
    ),
  );
}

class HotspotPartnerApp extends StatefulWidget {
  const HotspotPartnerApp({super.key});

  @override
  State<HotspotPartnerApp> createState() => _HotspotPartnerAppState();
}

class _HotspotPartnerAppState extends State<HotspotPartnerApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    final countryCode = prefs.getString('country');
    
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    } else if (countryCode != null) {
      final defaultLang = _getDefaultLanguageForCountry(countryCode);
      setState(() {
        _locale = Locale(defaultLang);
      });
    }
  }

  String _getDefaultLanguageForCountry(String country) {
    const frenchCountries = [
      'France',
      'Belgium',
      'Canada',
      'Ivory Coast',
      'Senegal',
    ];
    return frenchCountries.contains(country) ? 'fr' : 'en';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiknet Partner',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale != null) return _locale;
        
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/language': (context) => const LanguageScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-email-sent': (context) => const ResetEmailSentScreen(),
        '/set-new-password': (context) => const SetNewPasswordScreen(),
        '/password-success': (context) => const PasswordSuccessScreen(),
        '/profiles': (context) => const ProfilesScreen(),
        '/support': (context) => const SupportScreen(),
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
        '/internet-plan': (context) => const InternetPlanScreen(),
        '/subscription-management': (context) => const SubscriptionManagementScreen(),
        '/router-settings': (context) => const RouterSettingsScreen(),
        '/add-router': (context) => const AddRouterScreen(),
        '/user-roles': (context) => const UserRoleScreen(),
        '/worker-profile-setup': (context) => const WorkerProfileSetupScreen(),
        '/worker-activation': (context) => const WorkerActivationScreen(),
        '/revenue-breakdown': (context) => const RevenueBreakdownScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/router-details') {
          final router = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => RouterDetailsScreen(router: router as dynamic),
          );
        }
        if (settings.name == '/profile-editor') {
          return MaterialPageRoute(
            builder: (context) => const ProfilesScreen(),
          );
        }
        if (settings.name == '/create-edit-plan') {
          final planData = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => CreateEditInternetPlanScreen(planData: planData),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AppState>().currentUser;

    if (currentUser == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
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
    const TransactionsScreen(),
    const HealthScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi),
            label: 'Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.router),
            label: 'Router',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.watch<AppState>().currentUser?.name ?? 'Partner',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    context.watch<AppState>().currentUser?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await context.read<AppState>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
