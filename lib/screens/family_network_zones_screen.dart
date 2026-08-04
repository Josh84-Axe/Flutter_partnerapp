import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split/network_provider.dart';
import '../providers/family_provider.dart';
import '../models/router_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class FamilyNetworkZonesScreen extends StatefulWidget {
  const FamilyNetworkZonesScreen({super.key});

  @override
  State<FamilyNetworkZonesScreen> createState() => _FamilyNetworkZonesScreenState();
}

class _FamilyNetworkZonesScreenState extends State<FamilyNetworkZonesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkProvider>().loadRouters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Zones'),
      ),
      body: Consumer<NetworkProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.routers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.routers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadRouters(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final routers = provider.routers;
          
          if (routers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.router_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    const Text('No Network Zones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('You do not have any routers configured for your account yet.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              if (provider.isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Text(
                    'Offline Mode - Showing Cached Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.loadRouters,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: routers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final router = routers[index];
                      return _buildZoneCard(context, router);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Router functionality coming soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Zone'),
      ),
    );
  }

  Widget _buildZoneCard(BuildContext context, RouterModel router) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isOnline = router.status.toLowerCase() == 'online' || router.status.toLowerCase() == 'active';
    final color = isOnline ? colorScheme.primary : Colors.orange;
    final icon = isOnline ? Icons.wifi : Icons.wifi_off;

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
                      Text(router.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      if (router.ipAddress != null && router.ipAddress!.isNotEmpty)
                        Text('IP: ${router.ipAddress}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      
                      const SizedBox(height: 4),
                      Text(
                        isOnline ? 'Online' : 'Offline', 
                        style: TextStyle(
                          color: color, 
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                        )
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isOnline,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Toggling routers requires admin permission')),
                    );
                  },
                  activeTrackColor: color.withValues(alpha: 0.5),
                  activeThumbColor: color,
                ),
              ],
            ),
            if (router.lastSeen != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.history, size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Last seen: ${timeago.format(router.lastSeen!)}',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)
                  ),
                  const Spacer(),
                  if (router.connectedUsers > 0) ...[
                    Icon(Icons.people, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${router.connectedUsers} devices',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)
                    ),
                  ]
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showWifiSettingsBottomSheet(context),
                  icon: const Icon(Icons.wifi_lock),
                  label: const Text('Wi-Fi Password'),
                ),
                TextButton.icon(
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
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

  void _showWifiSettingsBottomSheet(BuildContext context) {
    final familyProvider = context.read<FamilyProvider>();
    final ssidController = TextEditingController(text: familyProvider.wifiSsid);
    final passController = TextEditingController(text: familyProvider.wifiPassphrase);
    bool obscurePassword = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wifi_lock, size: 28, color: Colors.indigo),
                      const SizedBox(width: 12),
                      const Text(
                        'Wi-Fi Credentials',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure your home Wi-Fi SSID and WPA2 Passphrase.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: ssidController,
                    decoration: InputDecoration(
                      labelText: 'Wi-Fi Network Name (SSID)',
                      prefixIcon: const Icon(Icons.wifi),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Wi-Fi Password (Passphrase)',
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setModalState(() => obscurePassword = !obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : () async {
                        final ssid = ssidController.text.trim();
                        final pass = passController.text.trim();
                        if (pass.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password must be at least 8 characters long')),
                          );
                          return;
                        }
                        setModalState(() => isSaving = true);
                        final success = await familyProvider.updateWifiSettings(ssid, pass);
                        setModalState(() => isSaving = false);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Wi-Fi credentials updated successfully!'
                                  : 'Failed to update Wi-Fi credentials.'),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
                      label: Text(isSaving ? 'Updating Router...' : 'Save & Push to Router'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
