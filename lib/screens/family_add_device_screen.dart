import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/family_provider.dart';
import '../services/family_api_service.dart';
import '../models/family_models.dart';

class FamilyAddDeviceScreen extends StatefulWidget {
  const FamilyAddDeviceScreen({super.key});

  @override
  State<FamilyAddDeviceScreen> createState() => _FamilyAddDeviceScreenState();
}

class _FamilyAddDeviceScreenState extends State<FamilyAddDeviceScreen> {
  bool _isLoading = true;
  List<UnclaimedDevice> _devices = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUnclaimedDevices();
  }

  Future<void> _fetchUnclaimedDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final devices = await FamilyApiService.fetchUnclaimedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to scan network for devices.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getIconForVendor(String vendor) {
    final lower = vendor.toLowerCase();
    if (lower.contains('apple') || lower.contains('iphone') || lower.contains('ipad') || lower.contains('mac')) return Icons.apple;
    if (lower.contains('samsung') || lower.contains('android') || lower.contains('galaxy') || lower.contains('redmi') || lower.contains('pixel')) return Icons.android;
    if (lower.contains('tv') || lower.contains('roku') || lower.contains('chromecast')) return Icons.tv;
    if (lower.contains('windows') || lower.contains('pc') || lower.contains('desktop') || lower.contains('laptop')) return Icons.computer;
    return Icons.devices_other;
  }

  void _showClaimDialog(UnclaimedDevice device) {
    final defaultName = (device.vendor.isNotEmpty && device.vendor != 'Unknown Brand' && device.vendor != 'Mobile Device (Private MAC)')
        ? device.vendor
        : (device.hostname.isNotEmpty && device.hostname != 'Mobile Device' && device.hostname != 'Unclaimed Device' && device.hostname != 'Unknown Device'
            ? device.hostname
            : 'My Device');
    final nameController = TextEditingController(text: defaultName);
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('claim_device'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('assign_friendly_name'.tr(), style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'device_name'.tr(),
                      hintText: 'e.g. Alex\'s iPad',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  Text('MAC: ${device.formattedMac}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => context.pop(),
                  child: Text('cancel'.tr()),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : () async {
                    if (nameController.text.trim().isEmpty) return;

                    setDialogState(() => isSubmitting = true);
                    final provider = context.read<FamilyProvider>();
                    
                    final success = await provider.registerDevice(
                      nameController.text.trim(),
                      device.macAddress,
                    );

                    if (mounted) {
                      setDialogState(() => isSubmitting = false);
                      if (success) {
                        setState(() {
                          _devices.removeWhere((d) => d.macAddress == device.macAddress);
                        });
                        context.pop(); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Device added successfully!'), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error ?? 'Failed to claim device'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: isSubmitting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('claim'.tr()),
                ),
              ],
            );
          }
        );
      },
    );
  }

  bool _isValidMacAddress(String input) {
    final clean = input.trim();
    final regex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$|^[0-9A-Fa-f]{12}$');
    return regex.hasMatch(clean);
  }

  void _showManualEntryDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final macController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('add_device_manually'.tr()),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'device_name'.tr(),
                        hintText: 'e.g. Maya\'s Tablet',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: macController,
                      decoration: InputDecoration(
                        labelText: 'mac_address'.tr(),
                        hintText: 'AA:BB:CC:DD:EE:FF',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!_isValidMacAddress(v)) return 'Invalid MAC address format (e.g. AA:BB:CC:DD:EE:FF)';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => context.pop(),
                  child: Text('cancel'.tr()),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : () async {
                    if (!formKey.currentState!.validate()) return;

                    setDialogState(() => isSubmitting = true);
                    final provider = context.read<FamilyProvider>();
                    
                    final success = await provider.registerDevice(
                      nameController.text.trim(),
                      macController.text.trim(),
                    );

                    if (mounted) {
                      setDialogState(() => isSubmitting = false);
                      if (success) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Device added successfully!'), backgroundColor: Colors.green),
                        );
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error ?? 'Failed to add device'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: isSubmitting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('network_discovery'.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchUnclaimedDevices,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showManualEntryDialog,
        icon: const Icon(Icons.add),
        label: Text('add_manually'.tr()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('scanning_network'.tr(), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('looking_for_new_devices'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _fetchUnclaimedDevices,
              child: Text('try_again'.tr()),
            ),
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_tethering_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('no_new_devices_found'.tr(), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('all_devices_managed'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'found_unmanaged_devices'.tr(namedArgs: {'count': '${_devices.length}'}),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _devices.length,
            itemBuilder: (context, index) {
              final device = _devices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        radius: 26,
                        child: Icon(_getIconForVendor(device.vendor), color: Theme.of(context).primaryColor, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  device.vendor != 'Unknown Brand' ? device.vendor : (device.hostname.isNotEmpty ? device.hostname : 'discovered_device'.tr()),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    device.deviceTypeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (device.hostname.isNotEmpty && device.hostname != device.vendor)
                              Text('Hostname: ${device.hostname}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('IP: ${device.ipAddress.isNotEmpty ? device.ipAddress : "DHCP Assigned"}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                            Text('MAC: ${device.formattedMac}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                            Text('Last seen: ${DateFormat.jm().format(device.lastSeen.toLocal())}', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () => _showClaimDialog(device),
                        child: Text('claim'.tr()),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
