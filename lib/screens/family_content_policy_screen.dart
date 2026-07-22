import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/family_provider.dart';
import '../models/family_models.dart';

class FamilyContentPolicyScreen extends StatefulWidget {
  final FamilyDevice device;

  const FamilyContentPolicyScreen({Key? key, required this.device}) : super(key: key);

  @override
  _FamilyContentPolicyScreenState createState() => _FamilyContentPolicyScreenState();
}

class _FamilyContentPolicyScreenState extends State<FamilyContentPolicyScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Policy: ${widget.device.deviceName}'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FamilyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.policies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.policies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No content policies available.', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () => provider.loadData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.blue, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Content Filter',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select a network-level filtering policy to enforce on this device.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: provider.policies.length,
                  itemBuilder: (context, index) {
                    final policy = provider.policies[index];
                    final isSelected = widget.device.activePolicyId == policy.id;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      elevation: isSelected ? 4 : 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isSaving 
                          ? null 
                          : () => _applyPolicy(context, provider, policy),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getIconForPolicy(policy.name),
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _formatPolicyName(policy.name),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Theme.of(context).primaryColor : null,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                policy.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: policy.categories.entries.map((entry) {
                                  final isActive = entry.value == true;
                                  return Chip(
                                    label: Text(
                                      _formatCategoryName(entry.key),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isActive ? Colors.white : Colors.grey[700],
                                      ),
                                    ),
                                    backgroundColor: isActive ? Colors.red[400] : Colors.grey[200],
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getIconForPolicy(String name) {
    if (name.contains('UNFILTERED')) return Icons.public;
    if (name.contains('CIPA')) return Icons.gavel;
    return Icons.family_restroom;
  }

  String _formatPolicyName(String name) {
    return name.replaceAll('TIKNET_POLICY_', '').replaceAll('_', ' ');
  }

  String _formatCategoryName(String key) {
    return key.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }

  Future<void> _applyPolicy(BuildContext context, FamilyProvider provider, ContentPolicy policy) async {
    setState(() => _isSaving = true);
    
    final success = await provider.setDevicePolicy(widget.device.id, policy);
    
    if (mounted) {
      setState(() => _isSaving = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.device.deviceName} updated to ${_formatPolicyName(policy.name)}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to apply policy'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
