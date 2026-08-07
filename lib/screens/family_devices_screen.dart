import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/family_provider.dart';
import '../models/family_models.dart';
import '../widgets/active_traffic_feed_widget.dart';
import '../widgets/confirmation_modal.dart';
import 'family_add_device_screen.dart';

class FamilyDevicesScreen extends StatefulWidget {
  const FamilyDevicesScreen({super.key});

  @override
  State<FamilyDevicesScreen> createState() => _FamilyDevicesScreenState();
}

class _FamilyDevicesScreenState extends State<FamilyDevicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FamilyDevice> _getFilteredDevices(List<FamilyDevice> devices) {
    if (_searchQuery.trim().isEmpty) return devices;
    final query = _searchQuery.toLowerCase().trim();
    return devices.where((d) {
      return d.deviceName.toLowerCase().contains(query) ||
             d.macAddress.toLowerCase().contains(query) ||
             d.vendor.toLowerCase().contains(query) ||
             (d.activePolicyName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _showPauseDurationModal(BuildContext context, FamilyDevice device, FamilyProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'Pause Internet on ${device.deviceName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                _buildPauseOption(context, Icons.timer, '15 Minutes', () {
                  provider.toggleDevicePause(device.id, true, durationMinutes: 15);
                }),
                _buildPauseOption(context, Icons.timer_10, '30 Minutes', () {
                  provider.toggleDevicePause(device.id, true, durationMinutes: 30);
                }),
                _buildPauseOption(context, Icons.hourglass_bottom, '1 Hour', () {
                  provider.toggleDevicePause(device.id, true, durationMinutes: 60);
                }),
                _buildPauseOption(context, Icons.hourglass_top, '2 Hours', () {
                  provider.toggleDevicePause(device.id, true, durationMinutes: 120);
                }),
                _buildPauseOption(context, Icons.edit_calendar, 'Custom Duration...', () {
                  _showCustomDurationDialog(context, device, provider);
                }),
                _buildPauseOption(context, Icons.pause_circle_filled, 'Indefinitely', () {
                  provider.toggleDevicePause(device.id, true);
                }, isDestructive: true),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPauseOption(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showCustomDurationDialog(BuildContext context, FamilyDevice device, FamilyProvider provider) {
    final minutesController = TextEditingController(text: '45');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Custom Pause for ${device.deviceName}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration in Minutes',
                    hintText: 'e.g. 45',
                    suffixText: 'mins',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    final mins = int.tryParse(val ?? '');
                    if (mins == null || mins <= 0) return 'Enter a valid number of minutes';
                    if (mins > 1440) return 'Max 1440 minutes (24 hours)';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final minutes = int.parse(minutesController.text.trim());
                  Navigator.pop(context);
                  provider.toggleDevicePause(device.id, true, durationMinutes: minutes);
                }
              },
              child: const Text('Apply Pause'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmRemoveDevice(BuildContext context, FamilyDevice device, FamilyProvider provider) async {
    final confirmed = await ConfirmationModal.show(
      context: context,
      title: 'Remove Device',
      message: 'Are you sure you want to remove "${device.deviceName}" from your family network?',
      confirmText: 'Remove',
      isDestructive: true,
    );

    if (confirmed == true) {
      final success = await provider.removeDevice(device.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '${device.deviceName} removed' : (provider.error ?? 'Failed to remove device')),
            backgroundColor: success ? Colors.orange : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<FamilyProvider>();
    final devices = _getFilteredDevices(provider.devices);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Family Devices', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadData(forceRefresh: true),
            tooltip: 'Refresh Devices',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadData(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Traffic Feed Widget
              ActiveTrafficFeedWidget(devices: provider.devices)
                  .animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 20),

              // Search Bar & Scan Button Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search devices by name or MAC...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FamilyAddDeviceScreen()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Scan Network for Devices',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Managed Devices (${devices.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.devices.where((d) => d.isOnline).length} Online',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (provider.isLoading && provider.devices.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (devices.isEmpty)
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.devices_other, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty ? 'No matching devices found' : 'No devices configured yet',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Try searching with a different device name or MAC address.'
                                : 'Scan your home network to add kids\' devices or enter MAC addresses manually.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const FamilyAddDeviceScreen()),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Device'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return _buildDeviceCard(context, device, provider, colorScheme)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 60 * index))
                        .slideY(begin: 0.1);
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FamilyAddDeviceScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, FamilyDevice device, FamilyProvider provider, ColorScheme colorScheme) {
    final policyName = device.activePolicyName != null
        ? device.activePolicyName!.replaceAll('TIKNET_POLICY_', '').replaceAll('_', ' ')
        : 'Default Filter';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: device.isPaused ? colorScheme.errorContainer : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.smartphone,
                    color: device.isPaused ? colorScheme.error : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MAC: ${device.macAddress}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: device.isPaused
                        ? colorScheme.errorContainer
                        : (device.isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: device.isPaused
                          ? colorScheme.error.withValues(alpha: 0.3)
                          : (device.isOnline ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        device.isPaused ? Icons.pause_circle : (device.isOnline ? Icons.check_circle : Icons.circle_outlined),
                        size: 12,
                        color: device.isPaused ? colorScheme.error : (device.isOnline ? Colors.green : Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        device.isPaused ? 'Paused' : (device.isOnline ? 'Online' : 'Offline'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: device.isPaused ? colorScheme.error : (device.isOnline ? Colors.green : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    context.push('/family-content-policy', extra: {'device': device});
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          policyName,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                  onPressed: () => _confirmRemoveDevice(context, device, provider),
                  tooltip: 'Remove Device',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (device.isPaused && device.pauseUntil != null)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: colorScheme.error),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Paused until ${DateFormat('MMM d, h:mm a').format(device.pauseUntil!.toLocal())}',
                            style: TextStyle(fontSize: 12, color: colorScheme.error, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      'Internet Access',
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                Switch(
                  value: !device.isPaused,
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green.withValues(alpha: 0.2),
                  inactiveThumbColor: colorScheme.error,
                  inactiveTrackColor: colorScheme.errorContainer,
                  onChanged: (val) {
                    if (!val) {
                      _showPauseDurationModal(context, device, provider);
                    } else {
                      provider.toggleDevicePause(device.id, false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
