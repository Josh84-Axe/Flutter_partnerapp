import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../flavors.dart';
import '../../providers/split/auth_provider.dart';

import '../../providers/campus_provider.dart';

import '../dashboard_screen.dart';
import '../users_screen.dart';
import '../plans_screen.dart';
import '../wallet_overview_screen.dart';

import '../family_dashboard_screen.dart';
import '../family_devices_screen.dart';
import '../family_rules_screen.dart';
import '../family_network_zones_screen.dart';

import '../campus_dashboard_screen.dart';
import '../campus_map_screen.dart';
import '../campus_support_screen.dart';

abstract class AppVariantStrategy {
  List<Widget> getScreens(BuildContext context, void Function(int) navigateTo);
  List<NavigationDestination> getDestinations();
  List<NavigationRailDestination> getRailDestinations();
  String getDrawerHeaderTitle();
  List<Widget> getDrawerItems(BuildContext context);
  Widget wrapShell(Widget child);
}

class PartnerVariantStrategy implements AppVariantStrategy {
  @override
  List<Widget> getScreens(BuildContext context, void Function(int) navigateTo) {
    return [
      const DashboardScreen(),
      const UsersScreen(),
      PlansScreen(onBack: () => navigateTo(0)),
      const WalletOverviewScreen(),
    ];
  }

  @override
  List<NavigationDestination> getDestinations() {
    return [
      NavigationDestination(icon: const Icon(Icons.dashboard), label: 'dashboard_title'.tr()),
      NavigationDestination(icon: const Icon(Icons.people), label: 'users'.tr()),
      NavigationDestination(icon: const Icon(Icons.wifi), label: 'plans'.tr()),
      NavigationDestination(icon: const Icon(Icons.account_balance_wallet), label: 'wallet'.tr()),
    ];
  }

  @override
  List<NavigationRailDestination> getRailDestinations() {
    return [
      NavigationRailDestination(icon: const Icon(Icons.dashboard), label: Text('dashboard_title'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.people), label: Text('users'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.wifi), label: Text('plans'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.account_balance_wallet), label: Text('wallet'.tr())),
    ];
  }

  @override
  String getDrawerHeaderTitle() => 'partner'.tr();

  @override
  List<Widget> getDrawerItems(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final routerCount = authProvider.currentUser?.numberOfRouters ?? 0;
    String subTier = 'subscription_none'.tr();
    if (routerCount == 1) {
      subTier = 'subscription_basic'.tr();
    } else if (routerCount >= 2 && routerCount <= 4) {
      subTier = 'subscription_standard'.tr();
    } else if (routerCount >= 5) {
      subTier = 'subscription_premium'.tr();
    }

    return [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('account'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.router_outlined),
        title: Text('hotspot_management'.tr()),
        onTap: () {
          context.pop();
          context.push('/hotspot-user');
        },
      ),
      ListTile(
        leading: const Icon(Icons.router),
        title: Text('router_configurations'.tr()),
        onTap: () {
          context.pop();
          context.push('/router-settings');
        },
      ),
      ListTile(
        leading: const Icon(Icons.wifi),
        title: Text('internet_plan'.tr()),
        onTap: () {
          context.pop();
          context.push('/internet-plans-settings');
        },
      ),
      ListTile(
        leading: const Icon(Icons.card_membership_outlined),
        title: Text('subscription_management'.tr()),
        subtitle: Text(subTier, style: const TextStyle(fontSize: 12)),
        onTap: () {
          context.pop();
          context.push('/subscription-management');
        },
      ),
      ListTile(
        leading: const Icon(Icons.health_and_safety_outlined),
        title: Text('router_health'.tr()),
        onTap: () {
          context.pop();
          context.push('/router-health');
        },
      ),
      ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: Text('notifications_preferences'.tr()),
        onTap: () {
          context.pop();
          context.push('/notification-settings');
        },
      ),
      ListTile(
        leading: const Icon(Icons.language_outlined),
        title: Text('language'.tr()),
        subtitle: Text(context.locale.languageCode.toUpperCase(), style: const TextStyle(fontSize: 12)),
        onTap: () {
          context.pop();
          context.push('/language');
        },
      ),
      ListTile(
        leading: const Icon(Icons.palette_outlined),
        title: Text('theme'.tr()),
        onTap: () {
          context.pop();
          context.push('/settings');
        },
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('security'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text('partner_profile'.tr()),
        onTap: () {
          context.pop();
          context.push('/partner-profile');
        },
      ),
      ListTile(
        leading: const Icon(Icons.security_outlined),
        title: Text('security_settings'.tr()),
        onTap: () {
          context.pop();
          context.push('/security/password-2fa');
        },
      ),
      ListTile(
        leading: const Icon(Icons.admin_panel_settings_outlined),
        title: Text('user_roles_permissions'.tr()),
        onTap: () {
          context.pop();
          context.push('/role-permissions');
        },
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('help_information'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.help_outline),
        title: Text('support_help'.tr()),
        onTap: () {
          context.pop();
          context.push('/support');
        },
      ),
      ListTile(
        leading: const Icon(Icons.info_outlined),
        title: Text('about'.tr()),
        onTap: () {
          context.pop();
          context.push('/about');
        },
      ),
    ];
  }

  @override
  Widget wrapShell(Widget child) => child;
}

class FamilyVariantStrategy implements AppVariantStrategy {
  @override
  List<Widget> getScreens(BuildContext context, void Function(int) navigateTo) {
    return [
      const FamilyDashboardScreen(),
      const FamilyDevicesScreen(),
      const FamilyRulesScreen(),
      const FamilyNetworkZonesScreen(),
    ];
  }

  @override
  List<NavigationDestination> getDestinations() {
    return [
      NavigationDestination(icon: const Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: const Icon(Icons.family_restroom), label: 'Family'),
      NavigationDestination(icon: const Icon(Icons.timer), label: 'Rules'),
      NavigationDestination(icon: const Icon(Icons.router), label: 'Network'),
    ];
  }

  @override
  List<NavigationRailDestination> getRailDestinations() {
    return [
      NavigationRailDestination(icon: const Icon(Icons.home), label: Text('family_app.nav.home'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.family_restroom), label: Text('family_app.nav.family'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.timer), label: Text('family_app.nav.rules'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.router), label: Text('family_app.nav.network'.tr())),
    ];
  }

  @override
  String getDrawerHeaderTitle() => 'Family Admin';

  @override
  List<Widget> getDrawerItems(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final routerCount = authProvider.currentUser?.numberOfRouters ?? 0;
    String subTier = 'subscription_none'.tr();
    if (routerCount == 1) {
      subTier = 'subscription_basic'.tr();
    } else if (routerCount >= 2 && routerCount <= 4) {
      subTier = 'subscription_standard'.tr();
    } else if (routerCount >= 5) {
      subTier = 'subscription_premium'.tr();
    }

    return [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('account'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.router),
        title: Text('router_configurations'.tr()),
        onTap: () {
          context.pop();
          context.push('/router-settings');
        },
      ),
      ListTile(
        leading: const Icon(Icons.card_membership_outlined),
        title: Text('subscription_management'.tr()),
        subtitle: Text(subTier, style: const TextStyle(fontSize: 12)),
        onTap: () {
          context.pop();
          context.push('/subscription-management');
        },
      ),
      ListTile(
        leading: const Icon(Icons.health_and_safety_outlined),
        title: Text('router_health'.tr()),
        onTap: () {
          context.pop();
          context.push('/router-health');
        },
      ),
      ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: Text('notifications_preferences'.tr()),
        onTap: () {
          context.pop();
          context.push('/notification-settings');
        },
      ),
      ListTile(
        leading: const Icon(Icons.language_outlined),
        title: Text('language'.tr()),
        subtitle: Text(context.locale.languageCode.toUpperCase(), style: const TextStyle(fontSize: 12)),
        onTap: () {
          context.pop();
          context.push('/language');
        },
      ),
      ListTile(
        leading: const Icon(Icons.palette_outlined),
        title: Text('theme'.tr()),
        onTap: () {
          context.pop();
          context.push('/settings');
        },
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('security'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text('partner_profile'.tr()),
        onTap: () {
          context.pop();
          context.push('/partner-profile');
        },
      ),
      ListTile(
        leading: const Icon(Icons.security_outlined),
        title: Text('security_settings'.tr()),
        onTap: () {
          context.pop();
          context.push('/security/password-2fa');
        },
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('help_information'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.help_outline),
        title: Text('support_help'.tr()),
        onTap: () {
          context.pop();
          context.push('/support');
        },
      ),
      ListTile(
        leading: const Icon(Icons.info_outlined),
        title: Text('about'.tr()),
        onTap: () {
          context.pop();
          context.push('/about');
        },
      ),
    ];
  }

  @override
  Widget wrapShell(Widget child) => child;
}

class CampusVariantStrategy implements AppVariantStrategy {
  @override
  List<Widget> getScreens(BuildContext context, void Function(int) navigateTo) {
    return [
      const CampusDashboardScreen(),
      const CampusMapScreen(),
      const CampusSupportScreen(),
    ];
  }

  @override
  List<NavigationDestination> getDestinations() {
    return [
      NavigationDestination(icon: const Icon(Icons.school), label: 'Campus Home'),
      NavigationDestination(icon: const Icon(Icons.map), label: 'Map'),
      NavigationDestination(icon: const Icon(Icons.help), label: 'Support'),
    ];
  }

  @override
  List<NavigationRailDestination> getRailDestinations() {
    return [
      NavigationRailDestination(icon: const Icon(Icons.school), label: Text('campus_app.nav.home'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.map), label: Text('campus_app.nav.map'.tr())),
      NavigationRailDestination(icon: const Icon(Icons.help), label: Text('campus_app.nav.support'.tr())),
    ];
  }

  @override
  String getDrawerHeaderTitle() => 'Campus Admin';

  @override
  List<Widget> getDrawerItems(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final routerCount = authProvider.currentUser?.numberOfRouters ?? 0;
    String subTier = 'subscription_none'.tr();
    if (routerCount == 1) {
      subTier = 'subscription_basic'.tr();
    } else if (routerCount >= 2 && routerCount <= 4) {
      subTier = 'subscription_standard'.tr();
    } else if (routerCount >= 5) {
      subTier = 'subscription_premium'.tr();
    }

    return [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('account'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.router_outlined),
        title: Text('hotspot_management'.tr()),
        onTap: () {
          context.pop();
          context.push('/hotspot-user');
        },
      ),
      ListTile(
        leading: const Icon(Icons.router),
        title: Text('router_configurations'.tr()),
        onTap: () {
          context.pop();
          context.push('/router-settings');
        },
      ),
      ListTile(
        leading: const Icon(Icons.wifi),
        title: Text('internet_plan'.tr()),
        onTap: () {
          context.pop();
          context.push('/internet-plans-settings');
        },
      ),
      ListTile(
        leading: const Icon(Icons.card_membership_outlined),
        title: Text('subscription_management'.tr()),
        subtitle: Text(subTier, style: const TextStyle(fontSize: 12)),
        onTap: () {
          context.pop();
          context.push('/subscription-management');
        },
      ),
      ListTile(
        leading: const Icon(Icons.health_and_safety_outlined),
        title: Text('router_health'.tr()),
        onTap: () {
          context.pop();
          context.push('/router-health');
        },
      ),
      ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: Text('notifications_preferences'.tr()),
        onTap: () {
          context.pop();
          context.push('/notification-settings');
        },
      ),
      ListTile(
        leading: const Icon(Icons.language_outlined),
        title: Text('language'.tr()),
        subtitle: Text(context.locale.languageCode.toUpperCase(), style: const TextStyle(fontSize: 12)),
        onTap: () {
          context.pop();
          context.push('/language');
        },
      ),
      ListTile(
        leading: const Icon(Icons.palette_outlined),
        title: Text('theme'.tr()),
        onTap: () {
          context.pop();
          context.push('/settings');
        },
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('security'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text('partner_profile'.tr()),
        onTap: () {
          context.pop();
          context.push('/partner-profile');
        },
      ),
      ListTile(
        leading: const Icon(Icons.security_outlined),
        title: Text('security_settings'.tr()),
        onTap: () {
          context.pop();
          context.push('/security/password-2fa');
        },
      ),
      ListTile(
        leading: const Icon(Icons.admin_panel_settings_outlined),
        title: Text('user_roles_permissions'.tr()),
        onTap: () {
          context.pop();
          context.push('/role-permissions');
        },
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
        child: Text('help_information'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
      ListTile(
        leading: const Icon(Icons.help_outline),
        title: Text('support_help'.tr()),
        onTap: () {
          context.pop();
          context.push('/support');
        },
      ),
      ListTile(
        leading: const Icon(Icons.info_outlined),
        title: Text('about'.tr()),
        onTap: () {
          context.pop();
          context.push('/about');
        },
      ),
    ];
  }

  @override
  Widget wrapShell(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => CampusProvider(),
      child: child,
    );
  }
}

AppVariantStrategy getStrategy(String? appVariant) {
  final variant = (appVariant != null && appVariant.isNotEmpty) ? appVariant : F.name;
  switch (variant) {
    case 'campus':
      return CampusVariantStrategy();
    case 'family':
      return FamilyVariantStrategy();
    default:
      return PartnerVariantStrategy();
  }
}
