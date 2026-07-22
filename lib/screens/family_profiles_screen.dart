import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_provider.dart';

class FamilyProfilesScreen extends StatelessWidget {
  const FamilyProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Devices & Rules'),
        centerTitle: true,
      ),
      body: Consumer<FamilyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.devices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.devices_other, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No devices found.', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => provider.loadData(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.devices.length,
            itemBuilder: (context, index) {
              final device = provider.devices[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.smartphone, color: Theme.of(context).primaryColor),
                  ),
                  title: Text(device.deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    device.activePolicyName != null 
                        ? 'Policy: ${device.activePolicyName!.replaceAll('TIKNET_POLICY_', '').replaceAll('_', ' ')}'
                        : 'No Filter Applied',
                    style: TextStyle(
                      color: device.activePolicyName != null ? Colors.green[700] : Colors.grey,
                    ),
                  ),
                  trailing: const Icon(Icons.shield_outlined),
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      '/family-content-policy',
                      arguments: {'device': device},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
