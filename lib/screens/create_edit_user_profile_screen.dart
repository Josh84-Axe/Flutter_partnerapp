import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/hotspot_profile_model.dart';
import '../providers/app_state.dart';

class CreateEditUserProfileScreen extends StatefulWidget {
  final HotspotProfileModel? profile;

  const CreateEditUserProfileScreen({super.key, this.profile});

  @override
  State<CreateEditUserProfileScreen> createState() => _CreateEditUserProfileScreenState();
}

class _CreateEditUserProfileScreenState extends State<CreateEditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedRateLimit;
  String? _selectedIdleTime;
  String? _selectedRouter;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _selectedRateLimit = widget.profile!.speedDescription;
      _selectedIdleTime = widget.profile!.idleTimeout;
    }
    
    // Fetch configurations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().fetchRateLimits();
      context.read<AppState>().fetchIdleTimeouts();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appState = context.watch<AppState>();
    final isEdit = widget.profile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_profile'.tr() : 'hotspot_user_profile'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'profile_name'.tr(),
                hintText: 'enter_profile_name'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'profile_name'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRateLimit,
              decoration: InputDecoration(
                labelText: 'rate_limit'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              hint: Text('select_rate_limit'.tr()),
              items: appState.rateLimits.isEmpty
                  ? [DropdownMenuItem<String>(value: null, child: Text('loading'.tr()))]
                  : appState.rateLimits
                      .map<DropdownMenuItem<String>>((limit) => DropdownMenuItem(value: limit.toString(), child: Text(limit.toString())))
                      .toList(),
              onChanged: (value) => setState(() => _selectedRateLimit = value),
              validator: (value) => value == null ? 'select_rate_limit'.tr() : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedIdleTime,
              decoration: InputDecoration(
                labelText: 'idle_time'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              hint: Text('select_idle_time'.tr()),
              items: appState.idleTimeouts.isEmpty
                  ? [DropdownMenuItem<String>(value: null, child: Text('loading'.tr()))]
                  : appState.idleTimeouts
                      .map<DropdownMenuItem<String>>((time) => DropdownMenuItem(value: time.toString(), child: Text(time.toString())))
                      .toList(),
              onChanged: (value) => setState(() => _selectedIdleTime = value),
              validator: (value) => value == null ? 'select_idle_time'.tr() : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRouter,
              decoration: InputDecoration(
                labelText: 'router'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              hint: Text('select_router'.tr()),
              items: [
                DropdownMenuItem(value: 'all', child: Text('all_routers'.tr())),
                ...appState.routers.map((router) =>
                    DropdownMenuItem(value: router.id, child: Text(router.name))),
              ],
              onChanged: (value) => setState(() => _selectedRouter = value),
              validator: (value) => value == null ? 'select_router'.tr() : null,
            ),
            const SizedBox(height: 24),
            if (appState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  appState.error!,
                  style: TextStyle(color: AppTheme.errorRed),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings_applications,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'profile_settings_info'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isEdit) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('delete_confirm_title'.tr()),
                        content: Text('delete_confirm_message'.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('cancel'.tr()),
                          ),
                          FilledButton(
                            onPressed: () {
                              // TODO: Implement delete profile in AppState
                              appState.hotspotProfiles.removeWhere((p) => p.id == widget.profile!.id);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.errorRed,
                            ),
                            child: Text('delete'.tr()),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppTheme.errorRed),
                    foregroundColor: AppTheme.errorRed,
                  ),
                  child: Text('delete'.tr()),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: appState.isLoading ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: appState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEdit ? 'save_profile'.tr() : 'create_profile'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();
    
    final data = {
      'name': _nameController.text,
      'rate_limit': _selectedRateLimit,
      'idle_timeout': _selectedIdleTime,
      // Add other fields as needed by the API
    };

    try {
      if (widget.profile != null) {
        await appState.updateHotspotProfile(widget.profile!.id, data);
      } else {
        await appState.createHotspotProfile(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Error is handled in AppState and displayed in UI
    }
  }
}
