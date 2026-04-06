import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/billing_provider.dart';
import '../providers/split/user_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  // Helper for inline detail chips
  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDateFilter = 'all'; // all, today, week, month
  bool _isLoading = false;
  
  // Cached list for total history
  List<dynamic> _allTransactions = [];

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
      _loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      final billingProvider = context.read<BillingProvider>();
      await billingProvider.loadAllTransactions();
      
      // Update local cached lists safely
      _updateLocalLists(billingProvider);
      
    } catch (e) {
      if (kDebugMode) print('Error loading transactions: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateLocalLists(BillingProvider billingProvider) {
    if (!mounted) return;
    
    try {
      // Safely map and merge
      final assigned = billingProvider.assignedTransactions.map((txn) => 
        Map<String, dynamic>.from(txn)..['transaction_type'] = 'assigned'
      ).toList();
      
      final wallet = billingProvider.walletTransactions.map((txn) => 
        Map<String, dynamic>.from(txn)..['transaction_type'] = 'wallet'
      ).toList();

      
      _allTransactions = [...assigned, ...wallet];
      
      // Sort desc by date
      _allTransactions.sort((a, b) {
        try {
          final aDate = DateTime.tryParse(a['created_at']?.toString() ?? a['createdAt']?.toString() ?? '');
          final bDate = DateTime.tryParse(b['created_at']?.toString() ?? b['createdAt']?.toString() ?? '');
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        } catch (_) {
          return 0;
        }
      });
      
    } catch (e) {
      if (kDebugMode) print('Error processing transaction lists: $e');
      _allTransactions = [];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  List<dynamic> _filterTransactions(List<dynamic> transactions) {
    var filtered = List<dynamic>.from(transactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((txn) {
        final description = (txn['description'] ?? '').toString().toLowerCase();
        final id = (txn['id'] ?? '').toString();
        final status = (txn['status'] ?? '').toString().toLowerCase();
        final typeField = (txn['transaction_type'] ?? txn['type'] ?? '').toString().toLowerCase();
        final routerName = (txn['router_name'] ?? '').toString().toLowerCase();
        final planName = (txn['plan_name'] ?? '').toString().toLowerCase();
        final workerName = (txn['worker_name'] ?? txn['assigned_by'] ?? '').toString().toLowerCase();
        final tag = (txn['tag'] ?? '').toString().toLowerCase();
        
        // Visual indicators virtual keywords
        final amountPaid = txn['amount_paid'];
        final amountValue = amountPaid != null 
            ? (double.tryParse(amountPaid.toString()) ?? 0.0)
            : (double.tryParse(txn['amount']?.toString() ?? '0') ?? 0.0);
        final amountSearch = amountValue.toString();
        
        final rawType = (txn['type'] ?? '').toString().toLowerCase();
        final isPayout = rawType == 'payout' || rawType == 'withdrawal' || rawType == 'debit';
        final isRevenue = !isPayout && amountValue >= 0;
        
        // Localized labels for better search
        final String localizedStatus = status == 'success' || status == 'completed' ? 'success'.tr() : (status == 'pending' ? 'pending'.tr() : 'failed'.tr());
        final String localizedType = typeField == 'assigned' ? 'assigned'.tr() : 'wallet'.tr();
        
        final query = _searchQuery.toLowerCase();
        
        return description.contains(query) ||
               amountSearch.contains(query) ||
               id.contains(query) ||
               status.contains(query) ||
               localizedStatus.toLowerCase().contains(query) ||
               typeField.contains(query) ||
               localizedType.toLowerCase().contains(query) ||
               routerName.contains(query) ||
               planName.contains(query) ||
               workerName.contains(query) ||
               tag.contains(query) ||
               (isRevenue && 'revenue'.tr().toLowerCase().contains(query)) ||
               (isPayout && 'payout'.tr().toLowerCase().contains(query)) ||
               (isPayout && 'withdrawal'.tr().toLowerCase().contains(query));
      }).toList();
    }

    // Apply date filter
    if (_selectedDateFilter != 'all') {
      final now = DateTime.now();
      filtered = filtered.where((txn) {
        try {
          final dateStr = txn['created_at'] ?? txn['createdAt'];
          if (dateStr == null) return false;
          
          final createdAt = DateTime.parse(dateStr.toString());
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
          return false;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // Watch state to trigger rebuilds on data change
    final billingProvider = context.watch<BillingProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final assignedRouters = user?.assignedRouters ?? [];
    final isRestricted = user?.role == 'worker' || user?.role == 'manager';

    List<dynamic> allTxnsSafe = [];
    try {
       // Create safe copies
       final safeAssigned = billingProvider.assignedTransactions.map((e) => safeMap(e, 'assigned')).toList();
       final safeWallet = billingProvider.walletTransactions.map((e) => safeMap(e, 'wallet')).toList();
       
       allTxnsSafe = [...safeAssigned, ...safeWallet];
       
       // RBAC Filter: Only show transactions from assigned routers if user is restricted
       if (isRestricted && assignedRouters.isNotEmpty) {
          allTxnsSafe = allTxnsSafe.where((t) {
             final rName = (t['router_name'] ?? '').toString();
             // System actions with no router hidden from workers
             if (rName.isEmpty) return false; 
             return assignedRouters.contains(rName);
          }).toList();
       }
       
       allTxnsSafe.sort((a, b) => safeDateCompare(a, b));
    } catch (e) {
       if (kDebugMode) print('Error building allTxns: $e');
    }

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
                _buildTransactionTab(allTxnsSafe, billingProvider), // All
                _buildTransactionTab(billingProvider.assignedTransactions, billingProvider, type: 'assigned'), // Assigned
                _buildTransactionTab(billingProvider.walletTransactions, billingProvider, type: 'wallet'), // Wallet
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper for safe list generation
  Map<String, dynamic> safeMap(dynamic item, String type) {
    if (item == null) return {'transaction_type': type};
    try {
      final m = Map<String, dynamic>.from(item);
      m['transaction_type'] = type;
      return m;
    } catch (_) {
      return {'transaction_type': type};
    }
  }
  
  int safeDateCompare(dynamic a, dynamic b) {
    try {
       final aDate = DateTime.tryParse(a['created_at']?.toString() ?? a['createdAt']?.toString() ?? '');
       final bDate = DateTime.tryParse(b['created_at']?.toString() ?? b['createdAt']?.toString() ?? '');
       if (aDate == null && bDate == null) return 0;
       if (aDate == null) return 1;
       if (bDate == null) return -1;
       return bDate.compareTo(aDate);
    } catch (_) {
      return 0;
    }
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

  Widget _buildTransactionTab(List<dynamic> sourceList, BillingProvider billingProvider, {String? type}) {
     // If explicit type provided, use it, else generic logic
     List<dynamic> filtered = _filterTransactions(sourceList);
     return _buildTransactionList(filtered, billingProvider, transactionType: type);
  }

  Widget _buildTransactionList(List<dynamic> transactions, BillingProvider billingProvider, {String? transactionType}) {
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
          try {
            final transaction = transactions[index];
            if (transaction == null) return const SizedBox();
            return _buildTransactionCard(transaction, billingProvider);
          } catch (e) {
            return const SizedBox(); // Skip broken items
          }
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

  Widget _buildTransactionCard(Map<String, dynamic> transaction, BillingProvider billingProvider) {
    // Parse amount from API - use amount_paid field
    final amountPaid = transaction['amount_paid'];
    final amount = amountPaid != null 
        ? (double.tryParse(amountPaid.toString()) ?? 0.0)
        : (double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0);
    
    final description = transaction['description'] ?? transaction['type'] ?? 'Transaction';
    final createdAt = transaction['created_at'] ?? transaction['createdAt'];
    final status = transaction['status'] ?? 'completed';
    final type = transaction['_type'] ?? transaction['transaction_type'] ?? '';
    final rawType = (transaction['type'] ?? '').toString().toLowerCase();
    
    // Identify if it's a payout/withdrawal
    final isPayout = rawType == 'payout' || rawType == 'withdrawal' || rawType == 'debit';

    // If it's a payout, treat as negative regardless of amount sign
    final isPositive = !isPayout && amount >= 0;
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTypeBadge(type),
                        const SizedBox(width: 8),
                        // Backend returns assigned_by. If null, it's a Voucher.
                        _buildTagBadge(
                          transaction['assigned_by'] ?? transaction['tag'] ?? transaction['worker_name'],
                          isAssigned: type == 'assigned',
                        ),
                        const SizedBox(width: 8),
                        // New details: Plan Name and Router Name
                        if (transaction['plan_name'] != null) ...[
                          _buildDetailChip(Icons.wifi_tethering, transaction['plan_name'].toString()),
                          const SizedBox(width: 8),
                        ],
                        if (transaction['router_name'] != null)
                          _buildDetailChip(Icons.router, transaction['router_name'].toString()),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}${billingProvider.formatMoney(amount.abs())}',
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

  Widget _buildTagBadge(dynamic tag, {bool isAssigned = false}) {
    // If tag exists, use it. If null and it's an assignment, it's a "Voucher" transaction.
    if (tag == null && !isAssigned) return const SizedBox.shrink();

    final String label = tag != null ? tag.toString() : 'voucher'.tr();
    final Color color = tag != null ? Colors.blueGrey : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
