import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/split/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/tiknet_themes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    // Check if user is a specific variant to conditionally show items
    final isPartner = currentUser?.appVariant == 'partner' || currentUser?.appVariant == null;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
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
                  currentUser?.name ?? 'partner'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentUser?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text('Subscription Plan Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/language');
            },
          ),
          
          // Theme Toggle inline for better UX
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (bool value) {
              final variant = value 
                ? TiknetThemeVariant.pillRoundedDark 
                : TiknetThemeVariant.flatLightGreen;
              themeProvider.setThemeVariant(variant);
            },
          ),
          
          if (isPartner) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_pin),
              title: const Text('Partner Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/partner-profile');
              },
            ),
          ],
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security and Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Support and Help'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/support');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),

          const Divider(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: FilledButton.icon(
              onPressed: () async {
                await authProvider.logout();
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
