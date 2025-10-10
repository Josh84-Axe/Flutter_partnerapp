import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class HotspotUserScreen extends StatefulWidget {
  const HotspotUserScreen({super.key});

  @override
  State<HotspotUserScreen> createState() => _HotspotUserScreenState();
}

class _HotspotUserScreenState extends State<HotspotUserScreen> {
  final _profileNameController = TextEditingController();
  String? _selectedRouterId;
  String _selectedIdleTimeout = '30min';
  String _selectedRateLimit = 'Standard';

  @override
  void dispose() {
    _profileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final routers = appState.routers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotspot User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Router Profile Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRouterId,
                      decoration: const InputDecoration(
                        labelText: 'Router Name',
                        border: OutlineInputBorder(),
                      ),
                      items: routers.map((router) {
                        return DropdownMenuItem(
                          value: router.id,
                          child: Text(router.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRouterId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _profileNameController,
                      decoration: const InputDecoration(
                        labelText: 'Profile Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedIdleTimeout,
                      decoration: const InputDecoration(
                        labelText: 'Idle Timeout (Predefined)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '15min', child: Text('Short (15 minutes)')),
                        DropdownMenuItem(value: '30min', child: Text('Standard (30 minutes)')),
                        DropdownMenuItem(value: '60min', child: Text('Long (60 minutes)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedIdleTimeout = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRateLimit,
                      decoration: const InputDecoration(
                        labelText: 'Rate Limit (Predefined)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Basic', child: Text('Basic - 10 Mbps')),
                        DropdownMenuItem(value: 'Standard', child: Text('Standard - 50 Mbps')),
                        DropdownMenuItem(value: 'Premium', child: Text('Premium - 100 Mbps')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRateLimit = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedRouterId == null ||
                              _profileNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all required fields'),
                              ),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hotspot user profile saved successfully'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
