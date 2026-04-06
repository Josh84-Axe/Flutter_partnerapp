import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/auth_provider.dart';
import 'dashboard_screen.dart';
import 'users_screen.dart';
import 'plans_screen.dart';
import 'wallet_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const UsersScreen(),
      PlansScreen(onBack: () => setState(() => _currentIndex = 0)),
      const WalletOverviewScreen(),
    ];
  }

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
                  context.watch<AuthProvider>().currentUser?.name ?? 'partner'.tr(),
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
