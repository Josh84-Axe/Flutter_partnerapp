import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/split/network_provider.dart';
import '../models/hotspot_profile_model.dart';
import '../utils/app_theme.dart';
import '../utils/error_message_helper.dart';

class CreateEditUserProfileScreen extends StatefulWidget {
  final HotspotProfileModel? profile;

  const CreateEditUserProfileScreen({super.key, this.profile});

  @override
  State<CreateEditUserProfileScreen> createState() => _CreateEditUserProfileScreenState();
}

class _CreateEditUserProfileScreenState extends State<CreateEditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  // Form state variables
  dynamic _selectedRateLimit;
  dynamic _selectedIdleTime;
  String? _selectedRouter;
  bool _isPromo = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    
    // Load configurations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkProvider>().loadAllConfigurations();
    });

    // Initialize form data if editing
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _isPromo = widget.profile!.isPromo;
      _isActive = widget.profile!.isActive;
      
      // Pre-select router if available
      if (widget.profile!.routerIds.isNotEmpty) {
        _selectedRouter = widget.profile!.routerIds.first;
      }
      
      // Note: Rate limit and Idle time matching might be tricky if the API 
      // returns formatted strings (e.g. "5m/5m") but the config list has objects.
      // We'll attempt to match by string representation or value if possible.
      // For now, we initialize them to null to force user selection if exact match fails,
      // or we could try to find a matching item in the list after loading config.
      // Given the "calibracres" issue, it's safer to let the user re-select or 
      // implement robust matching logic in build().
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final isEdit = widget.profile != null;
    final colorScheme = Theme.of(context).colorScheme;
    
    if (kDebugMode) print('🔧 [CreateEditProfile] Building screen. isEdit: $isEdit, profile: ${widget.profile?.name}, slug: ${widget.profile?.slug}');

    // Helper to get display text for Rate Limit / Idle Time items
    String getDisplayText(dynamic item) {
      if (item == null) return '';
      if (item is Map) {
        return item['name']?.toString() ?? item['value']?.toString() ?? item.toString();
      }
      return item.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_profile'.tr() : 'hotspot_user_profile'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'profile_name'.tr(),
                        hintText: 'enter_profile_name'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'profile_name_required'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Rate Limit Dropdown
                    DropdownButtonFormField<dynamic>(
                      value: _selectedRateLimit,
                      decoration: InputDecoration(
                        labelText: 'rate_limit'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.speed),
                      ),
                      hint: Text('select_rate_limit'.tr()),
                      items: networkProvider.rateLimits.isEmpty
                          ? [DropdownMenuItem(value: null, child: Text('loading'.tr()))]
                          : networkProvider.rateLimits.map((limit) {
                              return DropdownMenuItem(
                                value: limit,
                                child: Text(getDisplayText(limit)),
                              );
                            }).toList(),
                      onChanged: (value) => setState(() => _selectedRateLimit = value),
                      validator: (value) => value == null ? 'select_rate_limit'.tr() : null,
                    ),
                    const SizedBox(height: 16),

                    // Idle Timeout Dropdown
                    DropdownButtonFormField<dynamic>(
                      value: _selectedIdleTime,
                      decoration: InputDecoration(
                        labelText: 'idle_time'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.timer_outlined),
                      ),
                      hint: Text('select_idle_time'.tr()),
                      items: networkProvider.idleTimeouts.isEmpty
                          ? [DropdownMenuItem(value: null, child: Text('loading'.tr()))]
                          : networkProvider.idleTimeouts.map((timeout) {
                              return DropdownMenuItem(
                                value: timeout,
                                child: Text(getDisplayText(timeout)),
                              );
                            }).toList(),
                      onChanged: (value) => setState(() => _selectedIdleTime = value),
                      validator: (value) => value == null ? 'select_idle_time'.tr() : null,
                    ),
                    const SizedBox(height: 16),

                    // Router Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedRouter,
                      decoration: InputDecoration(
                        labelText: 'router'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.router_outlined),
                      ),
                      hint: Text('select_router'.tr()),
                      items: [
                        DropdownMenuItem(value: 'all', child: Text('all_routers'.tr())),
                        ...networkProvider.visibleRouters.map((router) =>
                            DropdownMenuItem(value: router.id, child: Text(router.name))),
                      ],
                      onChanged: (value) => setState(() => _selectedRouter = value),
                      validator: (value) => value == null ? 'select_router'.tr() : null,
                    ),
                    const SizedBox(height: 24),

                    // Switches
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text('promotional_profile'.tr()),
                            subtitle: Text('promotional_profile_desc'.tr()),
                            value: _isPromo,
                            onChanged: (value) => setState(() => _isPromo = value),
                            secondary: Icon(Icons.campaign, color: colorScheme.primary),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: Text('active_status'.tr()),
                            subtitle: Text('active_status_desc'.tr()),
                            value: _isActive,
                            onChanged: (value) => setState(() => _isActive = value),
                            secondary: Icon(Icons.toggle_on, color: _isActive ? Colors.green : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'profile_settings_info'.tr(),
                              style: TextStyle(color: colorScheme.primary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (isEdit) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (kDebugMode) print('🔴 DELETE BUTTON PRESSED!');
                          _confirmDelete(context, networkProvider);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                        ),
                        child: const Text('DELETE'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: networkProvider.isLoading ? null : () => _saveProfile(networkProvider),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: networkProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isEdit ? 'save_changes'.tr() : 'create_profile'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, NetworkProvider networkProvider) {
    if (kDebugMode) print('🗑️ [CreateEditProfile] Delete button clicked');
    if (kDebugMode) print('🗑️ [CreateEditProfile] Profile slug: ${widget.profile?.slug}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete "${widget.profile?.name ?? 'this profile'}"?'),
        actions: [
          TextButton(
            onPressed: () {
              if (kDebugMode) print('🗑️ [CreateEditProfile] Delete cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (kDebugMode) print('🗑️ [CreateEditProfile] Delete confirmed, slug: ${widget.profile!.slug}');
              Navigator.pop(context); // Close dialog
              try {
                final message = await networkProvider.deleteHotspotProfile(widget.profile!.slug);
                if (kDebugMode) print('✅ [CreateEditProfile] Delete successful: $message');
                if (mounted) {
                  Navigator.pop(context); // Close screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (kDebugMode) print('❌ [CreateEditProfile] Delete error: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ErrorMessageHelper.getUserFriendlyMessage(e, context: 'Profile')),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile(NetworkProvider networkProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Helper to extract ID from dynamic item (Map or String)
    dynamic extractId(dynamic item) {
      if (item is Map) {
        return item['id'] ?? item['value'];
      }
      return item;
    }

    final data = {
      'name': _nameController.text,
      'rate_limit': extractId(_selectedRateLimit),
      'idle_timeout': extractId(_selectedIdleTime),
      'is_for_promo': _isPromo,
      'is_active': _isActive,
      'routers': _selectedRouter != null && _selectedRouter != 'all' ? [_selectedRouter] : [],
    };

    if (kDebugMode) {
      print('📦 [CreateProfile] Saving profile data: $data');
      print('   Rate Limit Raw: $_selectedRateLimit');
      print('   Idle Time Raw: $_selectedIdleTime');
    }

    try {
      if (widget.profile != null) {
        await networkProvider.updateHotspotProfile(widget.profile!.slug, data);
      } else {
        await networkProvider.createHotspotProfile(data);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.profile != null ? 'profile_updated'.tr() : 'profile_created'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessageHelper.getUserFriendlyMessage(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
