import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/currency_utils.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
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
    });
    
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final appState = context.read<AppState>();
      await appState.loadAllTransactions();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> _filterTransactions(List<dynamic> transactions) {
    var filtered = transactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((txn) {
        final description = (txn['description'] ?? '').toString().toLowerCase();
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
          final createdAt = DateTime.parse(txn['created_at'] ?? txn['createdAt'] ?? '');
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
    final colorScheme = Theme.of(context).colorScheme;
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('transaction_history'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'all'.tr()),
            Tab(text: 'assigned'.tr()),
            Tab(text: 'wallet'.tr()),
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
                _buildAllTransactionsTab(appState),
                _buildAssignedTransactionsTab(appState),
                _buildWalletTransactionsTab(appState),
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

  Widget _buildAllTransactionsTab(AppState appState) {
    final allTransactions = [
      ...appState.assignedTransactions.map((txn) => {...txn, '_type': 'assigned'}),
      ...appState.walletTransactions.map((txn) => {...txn, '_type': 'wallet'}),
    ];

    // Sort by date (newest first)
    allTransactions.sort((a, b) {
      try {
        final aDate = DateTime.parse(a['created_at'] ?? a['createdAt'] ?? '');
        final bDate = DateTime.parse(b['created_at'] ?? b['createdAt'] ?? '');
        return bDate.compareTo(aDate);
      } catch (e) {
        return 0;
      }
    });

    final filtered = _filterTransactions(allTransactions);

    return _buildTransactionList(filtered, appState);
  }

  Widget _buildAssignedTransactionsTab(AppState appState) {
    final filtered = _filterTransactions(appState.assignedTransactions);
    return _buildTransactionList(filtered, appState, transactionType: 'assigned');
  }

  Widget _buildWalletTransactionsTab(AppState appState) {
    final filtered = _filterTransactions(appState.walletTransactions);
    return _buildTransactionList(filtered, appState, transactionType: 'wallet');
  }

  Widget _buildTransactionList(List<dynamic> transactions, AppState appState, {String? transactionType}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
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
    // Parse amount from API - use amount_paid field
    final amountPaid = transaction['amount_paid'];
    final amount = amountPaid != null 
        ? (amountPaid is String ? double.tryParse(amountPaid) ?? 0.0 : (amountPaid as num).toDouble())
        : (transaction['amount'] ?? 0).toDouble();
    
    final description = transaction['description'] ?? transaction['type'] ?? 'Transaction';
    final createdAt = transaction['created_at'] ?? transaction['createdAt'];
    final status = transaction['status'] ?? 'completed';
    final type = transaction['_type'] ?? transaction['transaction_type'] ?? '';

    final isPositive = amount >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          final transactionId = transaction['id']?.toString();
          final transactionType = type.isNotEmpty ? type : 'wallet';
          
          if (kDebugMode) {
            print('🔍 [TransactionHistory] Navigating to details:');
            print('   Transaction ID: $transactionId');
            print('   Transaction Type: $transactionType');
            print('   Full transaction data: $transaction');
          }
          
          Navigator.pushNamed(
            context,
            '/transaction-details',
            arguments: {
              'id': transactionId,
              'type': transactionType,
            },
          );
        },
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            description,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(_formatDate(createdAt)),
              if (type.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildTypeBadge(type),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${CurrencyUtils.formatPrice(amount.abs(), appState.partnerCountry)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusBadge(status),
            ],
          ),
          isThreeLine: type.isNotEmpty,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;

    switch (type) {
      case 'assigned':
        color = Colors.blue;
        label = 'assigned'.tr();
        break;
      case 'wallet':
        color = Colors.purple;
        label = 'wallet'.tr();
        break;
      default:
        color = Colors.grey;
        label = type;
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

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
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
