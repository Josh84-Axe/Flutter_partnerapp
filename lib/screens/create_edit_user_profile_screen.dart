import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/hotspot_profile_model.dart';
import '../providers/app_state.dart';
import '../services/hotspot_configuration_service.dart';

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isEdit = widget.profile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Profile' : 'Hotspot User Profile'),
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
                labelText: 'Profile Name',
                hintText: 'e.g., Premium-50Mbps',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a profile name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRateLimit,
              decoration: InputDecoration(
                labelText: 'Rate Limit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              hint: const Text('Select a rate limit'),
              items: HotspotConfigurationService.getRateLimits()
                  .map((limit) => DropdownMenuItem(value: limit, child: Text(limit)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedRateLimit = value),
              validator: (value) => value == null ? 'Please select a rate limit' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedIdleTime,
              decoration: InputDecoration(
                labelText: 'Idle Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              hint: const Text('Select an idle time'),
              items: HotspotConfigurationService.getIdleTimeouts()
                  .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedIdleTime = value),
              validator: (value) => value == null ? 'Please select an idle time' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRouter,
              decoration: InputDecoration(
                labelText: 'Router',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              hint: const Text('Select a router or group'),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Routers')),
                ...appState.routers.map((router) =>
                    DropdownMenuItem(value: router.id, child: Text(router.name))),
              ],
              onChanged: (value) => setState(() => _selectedRouter = value),
              validator: (value) => value == null ? 'Please select a router' : null,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings_applications,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These settings define the technical parameters for user connections, including speed limits, idle timeouts, and router associations. They are applied directly to the router configuration.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryGreen,
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
                        title: const Text('Delete Profile'),
                        content: const Text('Are you sure you want to delete this profile?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              appState.hotspotProfiles.removeWhere((p) => p.id == widget.profile!.id);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.errorRed,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.errorRed),
                    foregroundColor: AppTheme.errorRed,
                  ),
                  child: const Text('Delete'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _saveProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEdit ? 'Save Profile' : 'Create Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();

    final profile = HotspotProfileModel(
      id: widget.profile?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      downloadSpeedMbps: 50,
      uploadSpeedMbps: 50,
      idleTimeout: _selectedIdleTime!,
    );

    if (widget.profile != null) {
      final index = appState.hotspotProfiles.indexWhere((p) => p.id == widget.profile!.id);
      if (index != -1) {
        appState.hotspotProfiles[index] = profile;
      }
    } else {
      appState.hotspotProfiles.add(profile);
    }

    Navigator.pop(context);
  }
}
