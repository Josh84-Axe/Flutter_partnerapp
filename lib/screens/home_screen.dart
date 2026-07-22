import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/auth_provider.dart';
import 'dashboard_screen.dart';
import 'users_screen.dart';
import 'plans_screen.dart';
import 'wallet_overview_screen.dart';
import 'family_dashboard_screen.dart';
import 'campus_dashboard_screen.dart';

import 'family_profiles_screen.dart';
import 'family_network_zones_screen.dart';
import 'campus_map_screen.dart';
import 'campus_support_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> _getScreens(String? appVariant) {
    if (appVariant == 'campus') {
      return [
        const CampusDashboardScreen(),
        const CampusMapScreen(),
        const CampusSupportScreen(),
      ];
    }
    if (appVariant == 'family') {
      return [
        const FamilyDashboardScreen(),
        const FamilyProfilesScreen(),
        const Center(child: Text('Screen Time Rules (Coming Soon)')),
        const FamilyNetworkZonesScreen(),
      ];
    }
    // Default Partner Screens
    return [
      const DashboardScreen(),
      const UsersScreen(),
      PlansScreen(onBack: () => setState(() => _currentIndex = 0)),
      const WalletOverviewScreen(),
    ];
  }

  List<NavigationDestination> _getDestinations(String? appVariant) {
    if (appVariant == 'campus') {
      return [
        NavigationDestination(icon: const Icon(Icons.school), label: 'Campus Home'),
        NavigationDestination(icon: const Icon(Icons.map), label: 'Map'),
        NavigationDestination(icon: const Icon(Icons.help), label: 'Support'),
      ];
    }
    if (appVariant == 'family') {
      return [
        NavigationDestination(icon: const Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: const Icon(Icons.family_restroom), label: 'Family'),
        NavigationDestination(icon: const Icon(Icons.timer), label: 'Rules'),
        NavigationDestination(icon: const Icon(Icons.router), label: 'Network'),
      ];
    }
    // Default Partner Destinations
    return [
      NavigationDestination(icon: const Icon(Icons.dashboard), label: 'dashboard_title'.tr()),
      NavigationDestination(icon: const Icon(Icons.people), label: 'users'.tr()),
      NavigationDestination(icon: const Icon(Icons.wifi), label: 'plans'.tr()),
      NavigationDestination(icon: const Icon(Icons.account_balance_wallet), label: 'wallet'.tr()),
    ];
  }

  List<NavigationRailDestination> _getRailDestinations(String? appVariant) {
    if (appVariant == 'campus') {
      return [
        NavigationRailDestination(icon: const Icon(Icons.school), label: const Text('Campus Home')),
        NavigationRailDestination(icon: const Icon(Icons.map), label: const Text('Map')),
        NavigationRailDestination(icon: const Icon(Icons.help), label: const Text('Support')),
      ];
    }
    if (appVariant == 'family') {
      return [
        NavigationRailDestination(icon: const Icon(Icons.home), label: const Text('Home')),
        NavigationRailDestination(icon: const Icon(Icons.family_restroom), label: const Text('Family')),
        NavigationRailDestination(icon: const Icon(Icons.timer), label: const Text('Rules')),
        NavigationRailDestination(icon: const Icon(Icons.router), label: const Text('Network')),
      ];
    }
    // Default Partner Destinations
    return [
      NavigationRailDestination(icon: const Icon(Icons.dashboard), label: Text('dashboard_title'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.people), label: Text('users'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.wifi), label: Text('plans'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.account_balance_wallet), label: Text('wallet'.tr())),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final appVariant = context.watch<AuthProvider>().currentUser?.appVariant;
    final screens = _getScreens(appVariant);

    return Scaffold(
      body: Row(
        children: [
          if (isTablet)
            Builder(
              builder: (context) => NavigationRail(
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: _getRailDestinations(appVariant),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
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
              destinations: _getDestinations(appVariant),
            ),
      drawer: const AppDrawer(),
    );
  }
}
