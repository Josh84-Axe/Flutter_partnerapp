import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/campus_provider.dart';

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Wi-Fi Map'),
      ),
      body: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1541339907198-e08756dedf3f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
              ),
            ),
            child: const Center(
              child: Icon(Icons.location_on, size: 64, color: Colors.white),
            ),
          ),
          Expanded(
            child: Consumer<CampusProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.wifiZones.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.wifiZones.isEmpty) {
                  return const Center(child: Text('No Wi-Fi zones available at the moment.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text('Active Wi-Fi Zones', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...provider.wifiZones.map((zone) {
                      Color color = Colors.grey;
                      if (zone.color.toLowerCase() == 'green') color = Colors.green;
                      if (zone.color.toLowerCase() == 'orange') color = Colors.orange;
                      if (zone.color.toLowerCase() == 'red') color = Colors.red;

                      IconData iconData = Icons.wifi;
                      if (zone.iconName == 'local_library') iconData = Icons.local_library;
                      if (zone.iconName == 'restaurant') iconData = Icons.restaurant;
                      if (zone.iconName == 'hotel') iconData = Icons.hotel;
                      if (zone.iconName == 'science') iconData = Icons.science;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildZoneTile(
                          context,
                          name: zone.name,
                          status: zone.status,
                          users: zone.usersConnected,
                          icon: iconData,
                          color: color,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('GPS Navigation coming in next update')),
          );
        },
        child: const Icon(Icons.navigation),
      ),
    );
  }

  Widget _buildZoneTile(BuildContext context, {required String name, required String status, required int users, required IconData icon, required Color color}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(status),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, size: 16, color: Colors.grey),
          Text('$users', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connecting to $name Wi-Fi...')),
        );
      },
    );
  }
}
