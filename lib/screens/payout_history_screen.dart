import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/currency_utils.dart';
import '../utils/app_theme.dart';

class PayoutHistoryScreen extends StatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  State<PayoutHistoryScreen> createState() => _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends State<PayoutHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDateFilter = 'all'; // all, today, week, month
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Set initial tab from route arguments if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['initialTab'] != null) {
        final initialTab = args['initialTab'] as int;
        if (initialTab >= 0 && initialTab < 3) {
          _tabController.index = initialTab;
        }
      }
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final appState = context.read<AppState>();
      await Future.wait([
        appState.loadWalletTransactions(),
        appState.loadWithdrawals(),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _filterTransactions(List<Map<String, dynamic>> transactions) {
    var filtered = transactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((txn) {
        final description = (txn['description'] ?? txn['payment_reference'] ?? '').toString().toLowerCase();
        final amount = (txn['amount'] ?? '').toString();
        final id = (txn['id'] ?? '').toString();
        return description.contains(_searchQuery.toLowerCase()) ||
               amount.contains(_searchQuery) ||
               id.contains(_searchQuery);
      }).toList();
    }

    // Apply date filter
    if (_selectedDateFilter != 'all') {
      final now = DateTime.now();
      filtered = filtered.where((txn) {
        try {
          final createdAt = DateTime.parse(txn['created_at'] ?? '');
          switch (_selectedDateFilter) {
            case 'today':
              return createdAt.year == now.year &&
                     createdAt.month == now.month &&
                     createdAt.day == now.day;
            case 'week':
              final weekAgo = now.subtract(const Duration(days: 7));
              return createdAt.isAfter(weekAgo);
            case 'month':
              return createdAt.year == now.year && createdAt.month == now.month;
            default:
              return true;
          }
        } catch (e) {
          return true;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('payout_history'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'all'.tr()),
            Tab(text: 'payments_in'.tr()),
            Tab(text: 'payouts_out'.tr()),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search_transactions'.tr(),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                // Date Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'all'.tr()),
                      const SizedBox(width: 8),
                      _buildFilterChip('today', 'today'.tr()),
                      const SizedBox(width: 8),
                      _buildFilterChip('week', 'this_week'.tr()),
                      const SizedBox(width: 8),
                      _buildFilterChip('month', 'this_month'.tr()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(appState),
                _buildPaymentsInTab(appState),
                _buildPayoutsOutTab(appState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedDateFilter == value;
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedDateFilter = value);
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildAllTab(AppState appState) {
    final filtered = _filterTransactions(appState.walletHistory);
    return _buildTransactionList(filtered, appState);
  }

  Widget _buildPaymentsInTab(AppState appState) {
    final paymentsIn = appState.walletHistory
        .where((txn) => txn['_direction'] == 'in')
        .toList();
    final filtered = _filterTransactions(paymentsIn);
    return _buildTransactionList(filtered, appState);
  }

  Widget _buildPayoutsOutTab(AppState appState) {
    final payoutsOut = appState.walletHistory
        .where((txn) => txn['_direction'] == 'out')
        .toList();
    final filtered = _filterTransactions(payoutsOut);
    return _buildTransactionList(filtered, appState);
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions, AppState appState) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionCard(transaction, appState);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_transactions_found'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'try_different_search'.tr()
                : 'transactions_will_appear_here'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, AppState appState) {
    final direction = transaction['_direction'] ?? 'in';
    final isIn = direction == 'in';
    
    // Parse amount
    final amount = double.tryParse(transaction['amount']?.toString() ?? 
                                   transaction['amount_paid']?.toString() ?? '0') ?? 0.0;
    
    final description = transaction['description'] ?? 
                       transaction['payment_reference'] ?? 
                       transaction['type'] ?? 
                       'Transaction';
    final createdAt = transaction['created_at'];
    final status = transaction['status'] ?? 'completed';

    final color = isIn ? AppTheme.successGreen : AppTheme.errorRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to details
          if (!isIn) {
            // For payouts, show withdrawal details
            Navigator.pushNamed(
              context,
              '/withdrawal-details',
              arguments: {'withdrawal': transaction},
            );
          } else {
            // For payments, show transaction details
            final transactionId = transaction['id']?.toString();
            Navigator.pushNamed(
              context,
              '/transaction-details',
              arguments: {
                'id': transactionId,
                'type': 'wallet',
              },
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Direction Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIn ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${isIn ? '+' : '-'}${CurrencyUtils.formatPrice(amount.abs(), appState.partnerCountry)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    // Compact status stepper for payouts
                    if (!isIn)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildCompactStatusStepper(status),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'failed':
        color = Colors.red;
        label = 'Failed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCompactStatusStepper(String status) {
    final steps = [
      {'label': 'Requested', 'isActive': true},
      {'label': 'Processing', 'isActive': status.toLowerCase() != 'pending'},
      {'label': 'Completed', 'isActive': status.toLowerCase() == 'completed' || status.toLowerCase() == 'success'},
    ];

    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (steps[i]['isActive'] as bool) ? AppTheme.successGreen : Colors.grey[300],
            ),
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: (steps[i + 1]['isActive'] as bool) ? AppTheme.successGreen : Colors.grey[300],
              ),
            ),
        ],
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'today_at'.tr(args: [DateFormat('HH:mm').format(date)]);
      } else if (difference.inDays == 1) {
        return 'yesterday_at'.tr(args: [DateFormat('HH:mm').format(date)]);
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE, HH:mm').format(date);
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }
}
