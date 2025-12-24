import 'package:flutter/foundation.dart';
import '../../repositories/wallet_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/payment_method_repository.dart';
import '../../utils/currency_utils.dart'; // Assuming this exists, based on AppState usage
import '../../models/transaction_model.dart'; // Import TransactionModel

class BillingProvider with ChangeNotifier {
  WalletRepository? _walletRepository;
  TransactionRepository? _transactionRepository;
  PaymentMethodRepository? _paymentMethodRepository;

  bool _isLoading = false;
  String? _error;
  
  // Wallet state
  double _walletBalance = 0.0;
  double _totalRevenue = 0.0;
  double _onlineRevenue = 0.0;
  double _assignedRevenue = 0.0;
  double _assignedWalletBalance = 0.0; // Compatibility field
  String? _partnerCountry;
  
  // Transactions state
  List<TransactionModel> _transactions = []; // Type safety
  List<dynamic> _walletTransactions = [];
  List<dynamic> _assignedTransactions = [];
  List<dynamic> _assignedWalletTransactions = [];
  List<dynamic> _withdrawals = [];
  String? _lastWithdrawalId;
  
  // Payment Methods state
  List<dynamic> _paymentMethods = [];
  String? _paymentMethodOtpId;
  Map<String, dynamic>? _pendingPaymentMethodData;

  BillingProvider({
    WalletRepository? walletRepository,
    TransactionRepository? transactionRepository,
    PaymentMethodRepository? paymentMethodRepository,
    String? partnerCountry,
  }) : _walletRepository = walletRepository,
       _transactionRepository = transactionRepository,
       _paymentMethodRepository = paymentMethodRepository,
       _partnerCountry = partnerCountry;

  void update({
    WalletRepository? walletRepository,
    TransactionRepository? transactionRepository,
    PaymentMethodRepository? paymentMethodRepository,
    String? partnerCountry,
  }) {
    _walletRepository = walletRepository;
    _transactionRepository = transactionRepository;
    _paymentMethodRepository = paymentMethodRepository;
    _partnerCountry = partnerCountry;
  }

  // Getters
  double get walletBalance => _walletBalance;
  double get totalBalance => _walletBalance; // Mapped to current wallet balance
  double get totalRevenue => _totalRevenue;
  double get onlineRevenue => _onlineRevenue;
  double get assignedRevenue => _assignedRevenue;
  double get assignedWalletBalance => _assignedWalletBalance;
  
  // Helpers
  String get currencySymbol => CurrencyUtils.getCurrencySymbol(_partnerCountry);
  String formatMoney(double amount) => CurrencyUtils.formatPrice(amount, _partnerCountry);
  
  // Payout Helpers
  int get pendingPayoutsCount => _withdrawals
      .where((w) => (w['status'] ?? '').toString().toLowerCase() == 'pending')
      .length;
  
  double get pendingPayoutsTotal => _withdrawals
      .where((w) => (w['status'] ?? '').toString().toLowerCase() == 'pending')
      .fold(0.0, (sum, w) => sum + (double.tryParse(w['amount']?.toString() ?? '0') ?? 0));
  
  List<TransactionModel> get transactions => _transactions;
  List<dynamic> get walletTransactions => _walletTransactions;
  List<dynamic> get assignedTransactions => _assignedTransactions;
  List<dynamic> get assignedWalletTransactions => _assignedWalletTransactions;
  List<dynamic> get withdrawals => _withdrawals;

  // Wallet History Getters
  List<Map<String, dynamic>> get walletHistory {
    final combined = <Map<String, dynamic>>[];
    
    // Add wallet transactions as "IN"
    combined.addAll(_walletTransactions.map((txn) => {
      ...txn as Map<String, dynamic>,
      '_direction': 'in',
      '_source': 'wallet',
    }));
    
    // Add withdrawals as "OUT"
    combined.addAll(_withdrawals.map((withdrawal) => {
      ...withdrawal as Map<String, dynamic>,
      '_direction': 'out',
      '_source': 'withdrawal',
    }));
    
    // Sort by date (newest first)
    combined.sort((a, b) {
      try {
        final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate);
      } catch (e) {
        return 0;
      }
    });
    
    return combined;
  }
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  // ... (Helpers)

  /// Load wallet transactions (TransactionModel version)
  Future<void> loadTransactions() async {
    try {
      if (_walletRepository == null) return;
      
      // Fetch transactions from API
      final transactionsData = await _walletRepository!.fetchTransactions();
      _transactions = transactionsData.map<TransactionModel>((data) {
        // API uses 'amount_paid' not 'amount'
        final amount = double.tryParse(data['amount_paid']?.toString() ?? '0') ?? 0.0;
        
        return TransactionModel(
          id: data['id']?.toString() ?? '',
          amount: amount,
          type: data['type']?.toString() ?? 'unknown',
          status: data['status']?.toString() ?? 'pending',
          createdAt: data['created_at'] != null 
              ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          description: data['payment_reference']?.toString() ?? '', // Use payment_reference as description
          paymentMethod: data['payment_method']?.toString(),
          gateway: data['gateway']?.toString(),
          workerId: data['worker_id']?.toString(),
          accountId: data['account_id']?.toString(),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Load transactions error: $e');
      _setError(e.toString());
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Load wallet balance (current withdrawable funds)
  Future<void> loadWalletBalance() async {
    try {
      if (_walletRepository == null) return;
      
      if (kDebugMode) print('💰 [BillingProvider] Loading wallet balance...');
      final balanceData = await _walletRepository!.fetchBalance();
      
      if (balanceData != null) {
        // Handle both 'balance' and 'wallet_balance' keys for safety
        final balanceVal = balanceData['balance'] ?? balanceData['wallet_balance'];
        _walletBalance = CurrencyUtils.parseAmount(balanceVal);
        if (kDebugMode) print('✅ [BillingProvider] Wallet balance loaded: $_walletBalance');
      } else {
        if (kDebugMode) print('⚠️ [BillingProvider] No wallet balance data received');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Load wallet balance error: $e');
      _setError(e.toString());
    }
  }

  /// Load revenue counters (Total, Online, Assigned)
  Future<void> loadCountersBalance() async {
    try {
      if (_walletRepository == null) return;
      
      if (kDebugMode) print('💰 [BillingProvider] Loading revenue counters...');
      final countersData = await _walletRepository!.fetchBalance();
      
      if (kDebugMode) print('📊 [BillingProvider] Raw countersData: $countersData');
      
      if (countersData != null) {
        _totalRevenue = CurrencyUtils.parseAmount(countersData['total_revenue']);
        _onlineRevenue = CurrencyUtils.parseAmount(countersData['online_revenue_counter']);
        // Note: Backend has a typo 'assinged'
        _assignedRevenue = CurrencyUtils.parseAmount(countersData['assinged_revenue_counter']);
        
        // Map assigned revenue to deprecated field for compatibility
        _assignedWalletBalance = _assignedRevenue;
        
        if (kDebugMode) {
          print('✅ [BillingProvider] Counters loaded successfully:');
          print('   - Total Revenue: \$$_totalRevenue');
          print('   - Online Revenue: \$$_onlineRevenue');
          print('   - Assigned Revenue: \$$_assignedRevenue');
        }
      } else {
        if (kDebugMode) print('⚠️ [BillingProvider] No counters data received');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Load counters error: $e');
      _setError(e.toString());
    }
  }

  /// Load all balances (wallet and counters)
  Future<void> loadAllWalletBalances() async {
    await Future.wait([
      loadWalletBalance(),
      loadCountersBalance(),
    ]);
  }

  /// Load wallet transactions (online purchases)
  Future<void> loadWalletTransactions() async {
    try {
      if (_transactionRepository == null) return;
      
      if (kDebugMode) print('💳 [BillingProvider] Loading wallet transactions...');
      _walletTransactions = await _transactionRepository!.getWalletTransactions();
      
      if (kDebugMode) print('✅ [BillingProvider] Wallet transactions loaded: ${_walletTransactions.length}');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Load wallet transactions error: $e');
      _setError(e.toString());
    }
  }

  /// Load assigned plan transactions
  Future<void> loadAssignedTransactions() async {
    try {
      if (_transactionRepository == null) return;
      
      if (kDebugMode) print('💳 [BillingProvider] Loading assigned transactions...');
      _assignedTransactions = await _transactionRepository!.fetchAssignedPlanTransactions();
      
      if (kDebugMode) print('✅ [BillingProvider] Assigned transactions loaded: ${_assignedTransactions.length}');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Load assigned transactions error: $e');
      _setError(e.toString());
    }
  }

  /// Load assigned wallet transactions
  Future<void> loadAssignedWalletTransactions() async {
    try {
      if (_transactionRepository == null) return;
      
      if (kDebugMode) print('💳 [BillingProvider] Loading assigned wallet transactions...');
      _assignedWalletTransactions = await _transactionRepository!.getAssignedWalletTransactions();
      
      if (kDebugMode) print('✅ [BillingProvider] Assigned wallet transactions loaded: ${_assignedWalletTransactions.length}');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Load assigned wallet transactions error: $e');
      _setError(e.toString());
    }
  }

  /// Load all transactions (both assigned and wallet)
  Future<void> loadAllTransactions() async {
    await Future.wait([
      loadWalletTransactions(),
      loadAssignedTransactions(),
    ]);
  }

  /// Get transaction details by ID and type
  Future<Map<String, dynamic>> getTransactionDetails(String id, String type) async {
    try {
      if (_transactionRepository == null) throw Exception('Transaction repository not initialized');
      
      if (type == 'assigned') {
        return await _transactionRepository!.getAssignedTransactionDetails(id);
      } else {
        return await _transactionRepository!.getWalletTransactionDetails(id);
      }
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Get transaction details error: $e');
      rethrow;
    }
  }

  /// Load withdrawal history
  Future<void> loadWithdrawals() async {
    try {
      if (_transactionRepository == null) return;
      
      if (kDebugMode) print('💸 [BillingProvider] Loading withdrawals...');
      _withdrawals = await _transactionRepository!.getWithdrawals();
      
      if (kDebugMode) {
        print('✅ [BillingProvider] Withdrawals loaded: ${_withdrawals.length}');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Load withdrawals error: $e');
      _setError(e.toString());
    }
  }

  // Payment Method Getters
  List<dynamic> get paymentMethods => _paymentMethods;
  String? get paymentMethodOtpId => _paymentMethodOtpId;

  /// Load payment methods from API
  Future<void> loadPaymentMethods() async {
    try {
      if (_paymentMethodRepository == null) return;
      
      if (kDebugMode) print('💳 [BillingProvider] Loading payment methods...');
      _paymentMethods = await _paymentMethodRepository!.fetchPaymentMethods();
      
      if (kDebugMode) print('✅ [BillingProvider] Loaded ${_paymentMethods.length} payment methods');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Load payment methods error: $e');
      _setError(e.toString());
    }
  }

  /// Request OTP for creating payment method
  Future<Map<String, dynamic>?> requestPaymentMethodOtp(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_paymentMethodRepository == null) throw Exception('PaymentRepository not initialized');
      
      // Store data for later verification
      _pendingPaymentMethodData = data;
      
      final result = await _paymentMethodRepository!.requestCreateOtp(data);
      
      if (result['otp_id'] != null) {
        _paymentMethodOtpId = result['otp_id'].toString();
        notifyListeners();
        _setLoading(false);
        return result;
      }
      
      _setLoading(false);
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Request OTP error: $e');
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Verify OTP and create payment method
  Future<bool> verifyPaymentMethodOtp(String otp) async {
    _setLoading(true);
    try {
      if (_paymentMethodRepository == null) throw Exception('PaymentRepository not initialized');
      if (_paymentMethodOtpId == null || _pendingPaymentMethodData == null) {
        throw Exception('Missing OTP session data');
      }
      
      final success = await _paymentMethodRepository!.verifyCreateOtp(
        data: _pendingPaymentMethodData!,
        otp: otp,
        otpId: _paymentMethodOtpId!,
      );
      
      if (success != null) {
        // Clear pending data
        _pendingPaymentMethodData = null;
        _paymentMethodOtpId = null;
        notifyListeners();
        _setLoading(false);
        return true;
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Verify OTP error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Request payout/withdrawal
  Future<bool> requestPayout(double amount, String paymentMethodId) async {
    try {
      if (_transactionRepository == null) return false;
      
      if (kDebugMode) print('💸 [BillingProvider] Requesting payout: $amount to method: $paymentMethodId');
      
      final withdrawalData = {
        'amount': amount.toString(),
        'payment_method': paymentMethodId,
      };
      
      final result = await _transactionRepository!.createWithdrawal(withdrawalData);
      
      if (kDebugMode) print('✅ [BillingProvider] Payout requested successfully: ${result['id']}');
      
      // Store withdrawal ID for tracking
      _lastWithdrawalId = result['id']?.toString();
      
      // Reload wallet balance and transactions
      await Future.wait([
        loadAllWalletBalances(),
        loadAllTransactions(),
        loadWithdrawals(),
      ]);
      
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [BillingProvider] Request payout error: $e');
      _setError(e.toString());
      return false;
    }
  }
}

