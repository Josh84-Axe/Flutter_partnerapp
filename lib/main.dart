import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/app_state.dart';
import 'providers/theme_provider.dart';
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

class HotspotPartnerApp extends StatelessWidget {
  const HotspotPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      title: 'Hotspot Partner',
      theme: themeProvider.currentTheme,
      debugShowCheckedModeBanner: false,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.router),
            label: 'Health',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.deepGreen,
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
                      color: AppTheme.deepGreen,
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
