import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../models/hotspot_profile_model.dart';
import '../utils/app_theme.dart';

class HotspotUserScreen extends StatefulWidget {
  const HotspotUserScreen({super.key});

  @override
  State<HotspotUserScreen> createState() => _HotspotUserScreenState();
}

class _HotspotUserScreenState extends State<HotspotUserScreen> {
  String _searchQuery = '';

  void _navigateToCreateEdit({HotspotProfileModel? profile}) {
    Navigator.of(context).pushNamed('/create-edit-user-profile', arguments: profile);
  }

  void _showDeleteDialog(HotspotProfileModel profile) {
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('delete_profile'.tr())),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allProfiles = appState.hotspotProfiles;
    final filteredProfiles = allProfiles.where((profile) {
      return profile.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('hotspot_user_profiles'.tr()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_profiles'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredProfiles.length,
              itemBuilder: (context, index) {
                final profile = filteredProfiles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.speedDescription,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _navigateToCreateEdit(profile: profile),
                              icon: const Icon(Icons.edit),
                              style: IconButton.styleFrom(
                                foregroundColor: AppTheme.primaryGreen,
                                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _showDeleteDialog(profile),
                              icon: const Icon(Icons.delete),
                              style: IconButton.styleFrom(
                                foregroundColor: AppTheme.errorRed,
                                backgroundColor: AppTheme.errorRed.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _navigateToCreateEdit(),
                  icon: const Icon(Icons.add),
                  label: Text('add_new_profile'.tr()),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
