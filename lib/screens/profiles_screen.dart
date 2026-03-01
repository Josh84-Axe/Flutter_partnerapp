import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/network_provider.dart';
import '../widgets/search_bar_widget.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkProvider>().loadHotspotProfiles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final profiles = networkProvider.hotspotProfiles.where((profile) {
      if (_searchQuery.isEmpty) return true;
      return profile.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('hotspot_user_profiles'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: 'search_profiles'.tr(),
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: networkProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : profiles.isEmpty
                    ? Center(
                        child: Text(
                          'no_profiles_found_desc'.tr(),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.speed,
                                  color: colorScheme.primary,
                                ),
                              ),
                              title: Text(profile.name),
                              subtitle: Text(
                                '${profile.downloadSpeedMbps} Mbps ↓ / ${profile.uploadSpeedMbps} Mbps ↑ • ${profile.idleTimeout} idle',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        '/profile-editor',
                                        arguments: profile,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: colorScheme.error,
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('delete_profile'.tr()),
                                          content: Text(
                                            'delete_plan_confirm'.tr(namedArgs: {'name': profile.name}),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: Text('cancel'.tr()),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: Text(
                                                'delete'.tr(),
                                                style: TextStyle(color: colorScheme.error),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true && context.mounted) {
                                        try {
                                          final message = await networkProvider.deleteHotspotProfile(profile.slug);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(message),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('error_deleting_profile'.tr(namedArgs: {'error': e.toString()})),
                                                backgroundColor: colorScheme.error,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/profile-editor');
        },
        icon: const Icon(Icons.add),
        label: Text('add_new_profile'.tr()),
      ),
    );
  }
}
