import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/currency_utils.dart';

class AssignedPlansListScreen extends StatefulWidget {
  const AssignedPlansListScreen({super.key});

  @override
  State<AssignedPlansListScreen> createState() => _AssignedPlansListScreenState();
}

class _AssignedPlansListScreenState extends State<AssignedPlansListScreen> {
  bool _isLoading = false;
  List<dynamic> _assignedPlans = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignedPlans();
  }

  Future<void> _loadAssignedPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = context.read<AppState>();
      final plans = await appState.planRepository.fetchAssignedPlans();
      
      if (mounted) {
        setState(() {
          _assignedPlans = plans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_loading_assigned_plans'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredPlans {
    if (_searchQuery.isEmpty) {
      return _assignedPlans;
    }
    return _assignedPlans.where((plan) {
      final customerName = (plan['customer_name'] ?? '').toString().toLowerCase();
      final planName = (plan['plan_name'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return customerName.contains(query) || planName.contains(query);
    }).toList();
  }

  String _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'green';
      case 'expired':
        return 'red';
      case 'suspended':
        return 'orange';
      default:
        return 'grey';
    }
  }

  Color _getStatusColorValue(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appState = context.watch<AppState>();
    final partnerCountry = appState.currentUser?.country ?? 'Togo';
    final currencySymbol = CurrencyUtils.getCurrencySymbol(partnerCountry);

    return Scaffold(
      appBar: AppBar(
        title: Text('assigned_plans'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignedPlans,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_plans'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPlans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'no_assigned_plans'.tr()
                                  : 'no_plans_found'.tr(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'no_assigned_plans_desc'.tr()
                                  : 'try_different_search'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAssignedPlans,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredPlans.length,
                          itemBuilder: (context, index) {
                            final assignment = _filteredPlans[index];
                            final status = assignment['status'] ?? 'unknown';
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.wifi,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  assignment['customer_name'] ?? 'unknown_customer'.tr(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${'plan'.tr()}: ${assignment['plan_name'] ?? 'N/A'}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text('${'price'.tr()}: $currencySymbol${assignment['price'] ?? 'N/A'}'),
                                    Text('${'assigned_date'.tr()}: ${assignment['assigned_date'] ?? 'N/A'}'),
                                    if (assignment['expiry_date'] != null)
                                      Text('${'expiry_date'.tr()}: ${assignment['expiry_date']}'),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColorValue(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColorValue(status),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColorValue(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
