import 'package:flutter/material.dart';

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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text('Active Wi-Fi Zones', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildZoneTile(
                  context,
                  name: 'Main Library',
                  status: 'Strong Signal',
                  users: 142,
                  icon: Icons.local_library,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                _buildZoneTile(
                  context,
                  name: 'Student Center Cafeteria',
                  status: 'Moderate Signal',
                  users: 85,
                  icon: Icons.restaurant,
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildZoneTile(
                  context,
                  name: 'North Dormitory',
                  status: 'Strong Signal',
                  users: 312,
                  icon: Icons.hotel,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                _buildZoneTile(
                  context,
                  name: 'Science Building',
                  status: 'Maintenance',
                  users: 0,
                  icon: Icons.science,
                  color: Colors.red,
                ),
              ],
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
