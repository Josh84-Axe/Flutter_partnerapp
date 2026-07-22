import 'package:flutter/material.dart';

class FamilyNetworkZonesScreen extends StatelessWidget {
  const FamilyNetworkZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Zones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildZoneCard(
            context,
            name: 'Home Primary Wi-Fi',
            ssid: 'MyHome_5G',
            status: 'Active',
            icon: Icons.wifi,
            color: colorScheme.primary,
            isActive: true,
          ),
          const SizedBox(height: 16),
          _buildZoneCard(
            context,
            name: 'Guest Wi-Fi',
            ssid: 'MyHome_Guest',
            status: 'Inactive',
            icon: Icons.wifi_lock,
            color: Colors.orange,
            isActive: false,
          ),
          const SizedBox(height: 16),
          _buildZoneCard(
            context,
            name: 'Kids Network',
            ssid: 'MyHome_Kids',
            status: 'Active',
            icon: Icons.child_friendly,
            color: colorScheme.tertiary,
            isActive: true,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Zone functionality coming soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Zone'),
      ),
    );
  }

  Widget _buildZoneCard(BuildContext context, {required String name, required String ssid, required String status, required IconData icon, required Color color, required bool isActive}) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text('SSID: $ssid', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Toggling zones requires admin permission')),
                    );
                  },
                  activeColor: color,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share Password'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
