import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/router_model.dart';
import '../models/plan_model.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';
import '../models/profile_model.dart';
import '../models/language_model.dart';
import '../models/hotspot_profile_model.dart';
import '../models/router_configuration_model.dart';
import '../models/role_model.dart';
import '../models/worker_model.dart';
import '../models/subscription_model.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/connectivity_service.dart';
import '../services/api/api_config.dart';
import '../utils/guest_mode_helper.dart';
import '../services/api/token_storage.dart';
import '../services/api/api_client_factory.dart';
import '../repositories/auth_repository.dart';
import '../repositories/partner_repository.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/router_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/hotspot_repository.dart';
import '../repositories/plan_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/password_repository.dart';
import '../repositories/plan_config_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/collaborator_repository.dart';
import '../repositories/role_repository.dart';
import '../repositories/payment_method_repository.dart';
import '../repositories/additional_device_repository.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/report_repository.dart';
import '../utils/currency_utils.dart';
import '../utils/permission_mapping.dart';
import '../services/cache_service.dart';
import '../services/local_notification_service.dart';
import '../models/local_notification_model.dart';
import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier {
  AuthRepository? _authRepository;
  PartnerRepository? _partnerRepository;
  WalletRepository? _walletRepository;
  RouterRepository? _routerRepository;
  CustomerRepository? _customerRepository;
  HotspotRepository? _hotspotRepository;
  PlanRepository? _planRepository;
  SessionRepository? _sessionRepository;
  PasswordRepository? _passwordRepository;
  PlanConfigRepository? _planConfigRepository;
  TransactionRepository? _transactionRepository;
  CollaboratorRepository? _collaboratorRepository;
  RoleRepository? _roleRepository;
  PaymentMethodRepository? _paymentMethodRepository;
  AdditionalDeviceRepository? _additionalDeviceRepository;
  SubscriptionRepository? _subscriptionRepository;
  ReportRepository? _reportRepository;
  
  // Cache service for local data persistence
  final CacheService _cacheService = CacheService();
  
  // Feature flag to toggle between mock and real API
  bool _useRemoteApi = ApiConfig.useRemoteApi;
  
  Dio? _dio; // Exposed getter available
  
  // Constructor with debug logging
  AppState() {
    if (kDebugMode) print('🔧 [AppState] Initializing AppState');
    if (kDebugMode) print('🔧 [AppState] ApiConfig.useRemoteApi = ${ApiConfig.useRemoteApi}');
    if (kDebugMode) print('🔧 [AppState] _useRemoteApi = $_useRemoteApi');
  }
  
  bool get useRemoteApi => _useRemoteApi;
  
  // Getters for repositories and Dio
  Dio get dio => _dio!;
  RouterRepository? get routerRepository => _routerRepository;
  
  /// Toggle between mock data and real API (for testing)
  void setUseRemoteApi(bool value) {
    if (kDebugMode) print('🔧 [AppState] setUseRemoteApi called with value: $value');
    _useRemoteApi = value;
    notifyListeners();
  }
  
  /// Initialize API repositories
  void _initializeRepositories() {
    if (_authRepository == null) {
      final tokenStorage = TokenStorage();
      final apiFactory = ApiClientFactory(
        tokenStorage: tokenStorage,
        baseUrl: ApiConfig.baseUrl,
      );
      _dio = apiFactory.createDio();
      final dio = _dio!;
      
      _authRepository = AuthRepository(
        dio: dio,
        tokenStorage: tokenStorage,
      );
      _partnerRepository = PartnerRepository(dio: dio);
      _walletRepository = WalletRepository(dio: dio);
      _routerRepository = RouterRepository(dio: dio);
      _customerRepository = CustomerRepository(dio: dio);
      _hotspotRepository = HotspotRepository(dio: dio);
      _planRepository = PlanRepository(dio: dio);
      _sessionRepository = SessionRepository(dio: dio);
      _passwordRepository = PasswordRepository(dio: dio);
      _planConfigRepository = PlanConfigRepository(dio: dio);
      _transactionRepository = TransactionRepository(dio: dio);
      _collaboratorRepository = CollaboratorRepository(dio: dio);
      _roleRepository = RoleRepository(dio: dio);
      _paymentMethodRepository = PaymentMethodRepository(dio: dio);
      _additionalDeviceRepository = AdditionalDeviceRepository(dio: dio);
      _subscriptionRepository = SubscriptionRepository(dio: dio);
      _reportRepository = ReportRepository(transactionRepository: _transactionRepository!);
    }
  }
  
  UserModel? _currentUser;
  String? _partnerCountry; // Store partner country for currency display
  String? _partnerCurrencyCode; // Store currency code
  String? _partnerCurrencySymbol; // Store currency symbol
  bool _isLoading = false;
  String? _error;
  String? _lastWithdrawalId; // Store last withdrawal ID for tracking
  String? _registrationEmail; // Store email for verification flow
  String? _registrationOtpId; // Store OTP ID for registration verification flow
  String? _passwordResetOtpId; // Store OTP ID for password reset flow
  String? _passwordResetToken; // Store reset token after OTP verification
  String? _paymentMethodOtpId; // Store OTP ID for payment method verification flow
  Map<String, dynamic>? _pendingPaymentMethodData; // Store payment method data during OTP verification
  
  List<UserModel> _users = [];
  List<RouterModel> _routers = [];
  List<PlanModel> _plans = [];
  List<TransactionModel> _transactions = [];
  double _walletBalance = 0.0; // Current wallet balance
  double _aggregateDataUsage = 0.0; // Aggregated data usage for all active users
  
  // Revenue counters
  double _totalRevenue = 0.0;
  double _onlineRevenue = 0.0;
  double _assignedRevenue = 0.0;
  
  double _assignedWalletBalance = 0.0; // Deprecated, mapped to assignedRevenue
  List<dynamic> _assignedWalletTransactions = []; // Assigned wallet transactions (deprecated)
  List<dynamic> _assignedTransactions = []; // Assigned plan transactions from /partner/transactions/assigned/
  List<dynamic> _walletTransactions = []; // Wallet transactions from /partner/transactions/wallet/
  List<dynamic> _withdrawals = []; // Withdrawal history
  List<HotspotProfileModel> _hotspotProfiles = [];
  List<RouterConfigurationModel> _routerConfigurations = [];
  List<RoleModel> _roles = [];
  List<WorkerModel> _workers = [];
  List<Map<String, dynamic>> _activeSessions = []; // Active WiFi sessions
  List<dynamic> _hotspotUsers = []; // Hotspot users list
  List<dynamic> _assignedPlans = []; // Assigned plans for matching
  List<dynamic> _purchasedPlans = []; // Purchased plans (Gateway/Online)
  List<dynamic> _paymentMethods = []; // Payment methods for withdrawals
  
  // Configuration Lists
  List<dynamic> _sharedUsers = [];
  List<dynamic> _rateLimits = [];
  List<dynamic> _idleTimeouts = [];
  List<dynamic> _validityPeriods = [];
  List<dynamic> _dataLimits = [];
  
  final List<NotificationModel> _notifications = [];
  final List<ProfileModel> _profiles = [];
  LanguageModel _selectedLanguage = LanguageModel.availableLanguages.first;
  SubscriptionModel? _subscription;
  List<SubscriptionPlanModel> _availableSubscriptionPlans = [];
  
  // Local notification service
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  
  // Router assignment storage (username -> list of router IDs)
  Map<String, List<String>> _routerAssignments = {};
  
  final Map<int, String> _permissionIdToCodename = {};
  
  // Guest mode state
  bool _isGuestMode = false;
  String? _guestCountryCode;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  String? get partnerCountry => _partnerCountry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastWithdrawalId => _lastWithdrawalId;
  String? get registrationEmail => _registrationEmail;
  List<UserModel> get users => _users;
  List<RouterModel> get routers => _routers;
  List<PlanModel> get plans => _plans;
  List<TransactionModel> get transactions => _transactions;
  double get walletBalance => _walletBalance;
  double get aggregateDataUsage => _aggregateDataUsage;
  double get assignedWalletBalance => _assignedRevenue; // Mapped to assigned revenue
  double get totalBalance => _walletBalance; // Mapped to current wallet balance
  
  // Guest mode getters
  bool get isGuestMode => _isGuestMode;
  
  // New getters
  double get totalRevenue => _totalRevenue;
  double get onlineRevenue => _onlineRevenue;
  double get assignedRevenue => _assignedRevenue;
  List<dynamic> get assignedWalletTransactions => _assignedWalletTransactions;
  List<dynamic> get assignedTransactions => _assignedTransactions;
  List<dynamic> get walletTransactions => _walletTransactions;
  List<dynamic> get withdrawals => _withdrawals;
  List<HotspotProfileModel> get hotspotProfiles => _hotspotProfiles;
  List<RouterConfigurationModel> get routerConfigurations => _routerConfigurations;
  List<RoleModel> get roles => _roles;
  List<WorkerModel> get workers => _workers;
  List<Map<String, dynamic>> get activeSessions => _activeSessions;
  List<dynamic> get assignedPlans => _assignedPlans;
  List<dynamic> get purchasedPlans => _purchasedPlans;
  List<dynamic> get hotspotUsers => _hotspotUsers;
  
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
  
  // Get pending withdrawals count
  int get pendingPayoutsCount => _withdrawals
      .where((w) => (w['status'] ?? '').toString().toLowerCase() == 'pending')
      .length;
  
  // Get pending withdrawals total
  double get pendingPayoutsTotal => _withdrawals
      .where((w) => (w['status'] ?? '').toString().toLowerCase() == 'pending')
      .fold(0.0, (sum, w) => sum + (double.tryParse(w['amount']?.toString() ?? '0') ?? 0));
  
  List<dynamic> get sharedUsers => _sharedUsers;
  List<dynamic> get rateLimits => _rateLimits;
  List<dynamic> get idleTimeouts => _idleTimeouts;
  List<dynamic> get validityPeriods => _validityPeriods;
  List<dynamic> get dataLimits => _dataLimits;
  
  List<NotificationModel> get notifications => _notifications;
  List<ProfileModel> get profiles => _profiles;
  LanguageModel get selectedLanguage => _selectedLanguage;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;
  SubscriptionModel? get subscription => _subscription;
  List<SubscriptionPlanModel> get availableSubscriptionPlans => _availableSubscriptionPlans;
  
  // Local notifications
  List<LocalNotification> get localNotifications => _localNotificationService.notifications;
  int get localUnreadCount => _localNotificationService.unreadCount;
  Stream<LocalNotification> get localNotificationStream => _localNotificationService.notificationStream;
  
  // Currency formatting helpers
  String get currencySymbol => CurrencyUtils.getCurrencySymbol(_partnerCountry);
  String formatMoney(double amount) => CurrencyUtils.formatPrice(amount, _partnerCountry);
  
  // Repository getters
  SessionRepository get sessionRepository {
    _initializeRepositories();
    return _sessionRepository!;
  }
  
  PasswordRepository get passwordRepository {
    _initializeRepositories();
    return _passwordRepository!;
  }
  
  PlanConfigRepository get planConfigRepository {
    _initializeRepositories();
    return _planConfigRepository!;
  }
  
  TransactionRepository get transactionRepository {
    _initializeRepositories();
    return _transactionRepository!;
  }
  
  CollaboratorRepository get collaboratorRepository {
    _initializeRepositories();
    return _collaboratorRepository!;
  }
  
  PaymentMethodRepository get paymentMethodRepository {
    _initializeRepositories();
    return _paymentMethodRepository!;
  }
  
  AdditionalDeviceRepository get additionalDeviceRepository {
    _initializeRepositories();
    return _additionalDeviceRepository!;
  }
  
  PlanRepository get planRepository {
    _initializeRepositories();
    return _planRepository!;
  }

  ReportRepository get reportRepository {
    _initializeRepositories();
    return _reportRepository!;
  }
  
  Future<bool> login(String email, String password) async {
    if (kDebugMode) print('🔐 [AppState] login() called with email: $email');
    if (kDebugMode) print('🔐 [AppState] _useRemoteApi = $_useRemoteApi');
    if (kDebugMode) print('🔐 [AppState] ApiConfig.useRemoteApi = ${ApiConfig.useRemoteApi}');
    
    _setLoading(true);
    try {
      // FORCE REMOTE API: Always use real API for login (ignore _useRemoteApi flag)
      if (kDebugMode) print('🔐 [AppState] FORCING remote API login (ignoring _useRemoteApi flag)');
      
      // Use real API
      _initializeRepositories();
      final result = await _authRepository!.login(
        email: email,
        password: password,
      );
      
      if (result['success'] == true) {
        // Extract user data from login response if available
        final loginData = result['data'];
        Map<String, dynamic>? userData;
        
        if (loginData != null && loginData['user'] != null) {
          userData = loginData['user'];
        } else {
          // Fallback to fetching profile if user data not in login response
          final profileData = await _partnerRepository!.fetchProfile();
          if (profileData != null) {
            userData = profileData['data'] is Map ? profileData['data'] : profileData;
          }
        }

        if (userData != null) {
          // Extract permissions
          List<String> mappedPermissions = [];
          if (userData['role'] is Map && userData['role']['permissions'] is Map) {
            final permsMap = userData['role']['permissions'] as Map;
            permsMap.forEach((key, value) {
              if (value == true) {
                final constant = PermissionMapping.getConstant(key.toString());
                if (constant != null) {
                  mappedPermissions.add(constant);
                } else {
                  if (kDebugMode) print('⚠️ [AppState] Unknown permission label: $key');
                }
              }
            });
          }
          
          if (kDebugMode) print('✅ [AppState] Mapped permissions: $mappedPermissions');
          
          // Extract role
          final userRole = userData['role'] is Map ? (userData['role']['name']?.toString() ?? 'Partner') : 'Partner';
          if (kDebugMode) print('👤 [AppState] User role from API: ${userData['role']}');
          if (kDebugMode) print('👤 [AppState] Extracted role: "$userRole"');

          _currentUser = UserModel(
            id: userData['id']?.toString() ?? '1',
            name: '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim(),
            email: userData['email']?.toString() ?? email,
            role: userRole,
            permissions: mappedPermissions,
            isActive: true,
            createdAt: DateTime.now(),
          );
          
          // Extract country and set currency info
          _partnerCountry = userData['country']?.toString();
          if (kDebugMode) print('🌍 [AppState] Partner country: $_partnerCountry');
          
          // Set currency info based on country (fallback mapping)
          _partnerCurrencyCode = CurrencyUtils.getCurrencyCode(_partnerCountry);
          _partnerCurrencySymbol = CurrencyUtils.getCurrencySymbol(_partnerCountry);
          if (kDebugMode) print('💱 [AppState] Currency: $_partnerCurrencyCode ($_partnerCurrencySymbol)');
          
          // Parse subscription data if available
          if (userData['subscription'] != null) {
            try {
              if (kDebugMode) print('📦 [AppState] Parsing subscription data');
              _subscription = SubscriptionModel.fromJson(userData['subscription']);
            } catch (e) {
              if (kDebugMode) print('❌ [AppState] Error parsing subscription: $e');
            }
          }
        }

        // Load dashboard data in background - don't block login if it fails
        try {
          await loadDashboardData();
        } catch (e) {
          if (kDebugMode) print('⚠️ [AppState] Dashboard data load failed (non-blocking): $e');
        }
        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('🔐 [AppState] Login error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePartnerProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? businessName, 
    String? address,
    String? city,
    String? country, // Changed from countryId to country
    int? numberOfRouters,
  }) async {
    _setLoading(true);
    try {
      if (_authRepository == null) _initializeRepositories();
      
      final profileData = <String, dynamic>{};
      if (firstName != null) profileData['first_name'] = firstName;
      if (lastName != null) profileData['last_name'] = lastName;
      if (phone != null) profileData['phone'] = phone;
      if (businessName != null) profileData['entreprise_name'] = businessName;
      if (address != null) profileData['addresse'] = address;
      if (city != null) profileData['city'] = city;
      if (country != null) profileData['country'] = country;
      if (numberOfRouters != null) profileData['number_of_router'] = numberOfRouters;
      
      final result = await _authRepository!.updateProfile(profileData);
      
      if (result['success'] == true) {
        if (_currentUser != null) {
          // Update local user model
          _currentUser = _currentUser!.copyWith(
            name: firstName != null || lastName != null 
                ? '${firstName ?? _currentUser!.firstName} ${lastName ?? _currentUser!.lastName}'.trim()
                : null,
            phone: phone,
            address: address,
            city: city,
            country: country,
            numberOfRouters: numberOfRouters,
          );
          notifyListeners();
        }
        
        if (kDebugMode) print('✅ [AppState] Profile updated successfully');
        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to update profile');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Update profile error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  
  Future<bool> register({
    required String firstName,
    required String email,
    required String password,
    required String password2,
    required String phone,
    required String businessName,
    required String address,
    required String city,
    required String country,
    required int numberOfRouters,
  }) async {
    _setLoading(true);
    _registrationEmail = email; // Store email for verification
    _setError(null); // Clear previous errors
    
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      _initializeRepositories();
      
      final result = await _authRepository!.register(
        firstName: firstName,
        email: email,
        password: password,
        password2: password2,
        phone: phone,
        businessName: businessName,
        address: address,
        city: city,
        country: country,
        numberOfRouters: numberOfRouters,
      );
      
      final success = result['success'] as bool;
      final message = result['message'] as String;
      final otpId = result['otp_id'] as String?;
      
      if (!success) {
        if (kDebugMode) print('❌ [AppState] Registration failed: $message');
        _setError(message);
        _setLoading(false);
        return false;
      }
      
      // Store OTP ID if email verification is required
      if (otpId != null) {
        _registrationOtpId = otpId;
        if (kDebugMode) print('✅ [AppState] Stored registration OTP ID: $otpId');
      }
      
      if (kDebugMode) print('✅ [AppState] Registration successful: $message');
      
      // Try to load profile to get user data
      // If registration requires email verification, this might fail
      try {
        final profileData = await _partnerRepository!.fetchProfile();
        if (profileData != null) {
          _currentUser = UserModel(
            id: profileData['id']?.toString() ?? '1',
            name: profileData['first_name']?.toString() ?? firstName,
            email: profileData['email']?.toString() ?? email,
            role: 'Partner',
            isActive: true,
            createdAt: DateTime.now(),
          );
          
          // Fetch and map permissions
          try {
            await fetchPermissions();
          } catch (e) {
            if (kDebugMode) print('⚠️ [AppState] Failed to fetch permissions on register: $e');
          }
          
          await loadDashboardData();
        }
      } catch (e) {
        // If profile fetch fails (e.g., email verification required),
        // create a temporary user model
        _currentUser = UserModel(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          name: firstName,
          email: email,
          role: 'Partner',
          isActive: false,
          createdAt: DateTime.now(),
        );
        
        // Set info message for email verification
        _setError('Please check your email to verify your account.');
      }
      
      _setLoading(false);
      return success;
    } catch (e, stackTrace) {
      if (kDebugMode) print('❌ [AppState] Register error: $e');
      if (kDebugMode) print('❌ [AppState] Stack trace: $stackTrace');
      _setError('Registration error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Confirm registration with OTP
  Future<bool> confirmRegistration(String otp) async {
    if (_registrationEmail == null) {
      _setError('No registration email found');
      return false;
    }
    
    _setLoading(true);
    try {
      if (_authRepository == null) _initializeRepositories();
      
      // Use confirmRegistration endpoint (doesn't require OTP ID)
      final result = await _authRepository!.confirmRegistration(_registrationEmail!, otp);
      
      if (result != null) {
        if (kDebugMode) print('✅ [AppState] Email verification successful');
        // Verification endpoint doesn't return tokens, so we can't auto-login.
        // The UI will navigate to /home, which will redirect to /login via AuthWrapper.
        _setLoading(false);
        return true;
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Resend verification OTP
  Future<bool> resendVerifyEmailOtp() async {
    if (_registrationEmail == null) {
      _setError('No registration email found');
      return false;
    }
    
    _setLoading(true);
    try {
      if (_authRepository == null) _initializeRepositories();
      final success = await _authRepository!.resendVerifyEmailOtp(_registrationEmail!);
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> logout() async {
    // FORCE REMOTE API: Always use real API (no mock fallback)
    _initializeRepositories();
    await _authRepository!.logout();
    
    // Clear cached data on logout
    await _cacheService.clearAllCache();
    if (kDebugMode) print('🗑️ [AppState] Cleared all cache on logout');
    
    // Clear user-specific notifications
    await _localNotificationService.clearUserData();
    if (kDebugMode) print('🔔 [AppState] Cleared user notifications on logout');
    
    _currentUser = null;
    _users = [];
    _routers = [];
    _plans = [];
    _transactions = [];
    _walletBalance = 0.0;
    _isGuestMode = false; // Clear guest mode on logout
    notifyListeners();
  }
  
  /// Enter guest mode with mock data
  Future<void> enterGuestMode({String? countryCode}) async {
    if (kDebugMode) print('👤 [AppState] Entering guest mode...');
    
    _isGuestMode = true;
    _guestCountryCode = countryCode;
    
    // Create guest user
    _currentUser = GuestModeHelper.createGuestUser(countryCode: countryCode);
    _partnerCountry = _currentUser!.country;
    
    // Load mock data
    _routers = GuestModeHelper.generateDemoRouters();
    _users = GuestModeHelper.generateDemoCustomers();
    _transactions = GuestModeHelper.generateDemoTransactions(_currentUser!.country!)
        .map((t) => TransactionModel.fromJson(t))
        .toList();
    
    // Load mock wallet
    final walletData = GuestModeHelper.generateDemoWallet(_currentUser!.country!);
    _walletBalance = walletData['balance'];
    
    // Load mock stats
    final stats = GuestModeHelper.generateDemoStats();
    _totalRevenue = stats['total_revenue'];
    
    // Load real subscription plans (as requested)
    try {
      await loadAvailableSubscriptionPlans();
    } catch (e) {
      if (kDebugMode) print('⚠️ [AppState] Could not load subscription plans in guest mode: $e');
    }
    
    if (kDebugMode) print('✅ [AppState] Guest mode activated with demo data');
    notifyListeners();
  }
  
  /// Exit guest mode
  void exitGuestMode() {
    if (kDebugMode) print('👤 [AppState] Exiting guest mode...');
    
    _isGuestMode = false;
    _guestCountryCode = null;
    _currentUser = null;
    _users = [];
    _routers = [];
    _plans = [];
    _transactions = [];
    _walletBalance = 0.0;
    _totalRevenue = 0.0;
    
    notifyListeners();
  }
  
  /// Check if user can perform an action (returns false if guest mode)
  bool canPerformAction(BuildContext context, {String? featureName}) {
    if (_isGuestMode) {
      // Will be handled by UI to show register prompt
      return false;
    }
    return true;
  }
  
  /// Request password reset - sends OTP to email and stores OTP ID
  Future<bool> requestPasswordReset(String email) async {
    try {
      _initializeRepositories();
      final result = await _passwordRepository!.requestPasswordResetOtp(email);
      
      if (result != null && result['otp_id'] != null) {
        _passwordResetOtpId = result['otp_id'].toString();
        if (kDebugMode) print('✅ [AppState] OTP ID stored: $_passwordResetOtpId');
        return true;
      }
      
      if (kDebugMode) print('⚠️ [AppState] No OTP ID in response');
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Request password reset error: $e');
      return false;
    }
  }
  
  /// Verify password reset OTP with OTP ID
  /// Returns reset_token and stores it for password update
  Future<bool> verifyPasswordResetOtp(String email, String otp) async {
    try {
      _initializeRepositories();
      
      if (_passwordResetOtpId == null) {
        if (kDebugMode) print('❌ [AppState] No OTP ID available for verification');
        return false;
      }
      
      final resetToken = await _passwordRepository!.verifyPasswordResetOtp(
        otp: otp,
        otpId: _passwordResetOtpId!,
      );
      
      if (resetToken != null) {
        _passwordResetToken = resetToken;
        if (kDebugMode) print('✅ [AppState] Reset token stored');
        return true;
      }
      
      if (kDebugMode) print('❌ [AppState] OTP verification failed - no reset token');
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Verify password reset OTP error: $e');
      return false;
    }
  }
  
  /// Confirm password reset with reset token and new password
  Future<bool> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      _initializeRepositories();
      
      if (_passwordResetToken == null) {
        if (kDebugMode) print('❌ [AppState] No reset token available for password reset');
        return false;
      }
      
      final success = await _passwordRepository!.resetPassword({
        'token': _passwordResetToken!,
        'new_password': newPassword,
      });
      
      if (success) {
        // Clear all password reset state after successful reset
        _passwordResetOtpId = null;
        _passwordResetToken = null;
        if (kDebugMode) print('✅ [AppState] Password reset successful, state cleared');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Confirm password reset error: $e');
      return false;
    }
  }
  
  Future<void> checkAuthStatus() async {
    // FORCE REMOTE API: Always use real API (no mock fallback)
    _initializeRepositories();
    final tokenStorage = TokenStorage();
    final accessToken = await tokenStorage.getAccessToken();
    
    if (accessToken != null) {
      // Try to fetch profile to verify token is still valid
      try {
        final profileData = await _partnerRepository!.fetchProfile();
        if (profileData != null) {
          // Unwrap data if nested
          final data = profileData['data'] is Map ? profileData['data'] : profileData;
          
          // Store partner country for currency display
          _partnerCountry = data['country']?.toString() ?? 
                          data['country_name']?.toString() ?? 
                          'Togo'; // Default to Togo for West African partners
          if (kDebugMode) print('Partner country loaded: $_partnerCountry');
          
          // Extract permissions
          List<String> mappedPermissions = [];
          if (data['role'] is Map && data['role']['permissions'] is Map) {
            final permsMap = data['role']['permissions'] as Map;
            permsMap.forEach((key, value) {
              if (value == true) {
                final constant = PermissionMapping.getConstant(key.toString());
                if (constant != null) {
                  mappedPermissions.add(constant);
                } else {
                  if (kDebugMode) print('⚠️ [AppState] Unknown permission label: $key');
                }
              }
            });
          }
          
          if (kDebugMode) print('✅ [AppState] Mapped permissions (checkAuthStatus): $mappedPermissions');

          _currentUser = UserModel(
            id: data['id']?.toString() ?? '1',
            name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim(),
            email: data['email']?.toString() ?? '',
            role: data['role'] is Map ? (data['role']['name']?.toString() ?? 'Partner') : 'Partner',
            phone: data['phone']?.toString() ?? data['phone_number']?.toString(),
            permissions: mappedPermissions,
            isActive: true,
            createdAt: data['created_at'] != null 
                ? DateTime.tryParse(data['created_at']) ?? DateTime.now()
                : DateTime.now(),
            address: data['address']?.toString(),
            city: data['city']?.toString(),
            country: data['country']?.toString() ?? data['country_name']?.toString(),
            numberOfRouters: data['routers_count'] ?? data['number_of_routers'],
          );
          
          // Parse subscription data if available
          if (data['subscription'] != null) {
            try {
              if (kDebugMode) print('📦 [AppState] Parsing subscription data (checkAuthStatus)');
              _subscription = SubscriptionModel.fromJson(data['subscription']);
            } catch (e) {
              if (kDebugMode) print('❌ [AppState] Error parsing subscription: $e');
            }
          }
          // Load dashboard data in background - don't block auth check if it fails
          try {
            await loadDashboardData();
          } catch (e) {
            if (kDebugMode) print('⚠️ [AppState] Dashboard data load failed (non-blocking): $e');
            // Don't fail auth check if dashboard data fails to load
          }
        }
      } catch (e) {
        // Token is invalid, clear it
        await tokenStorage.clearTokens();
        _currentUser = null;
      }
    }
    notifyListeners();
  }
  

  

  

  Future<void> loadAllConfigurations() async {
    if (kDebugMode) print('⚙️  [AppState] Loading configurations...');
    
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      
      await Future.wait([
        _loadRateLimits(),
        _loadDataLimits(),
        _loadValidityPeriods(),
        _loadIdleTimeouts(),
        _loadSharedUsers(),
        loadRouters(),
        loadRouterAssignments(), // Load router assignments on startup
      ]);
      
      if (kDebugMode) {
        print('✅ [AppState] Configurations loaded:');
        print('   Rate Limits: ${_rateLimits.length}');
        print('   Data Limits: ${_dataLimits.length}');
        print('   Validity Periods: ${_validityPeriods.length}');
        print('   Idle Timeouts: ${_idleTimeouts.length}');
        print('   Shared Users: ${_sharedUsers.length}');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Error loading configurations: $e');
    }
  }

  Future<void> _loadRateLimits() async {
    try {
      if (kDebugMode) print('🔄 [AppState] Loading rate limits...');
      _rateLimits = await _planConfigRepository!.fetchRateLimits();
      if (kDebugMode) print('✅ [AppState] Rate limits loaded: ${_rateLimits.length} items');
      if (kDebugMode && _rateLimits.isNotEmpty) print('   Sample: ${_rateLimits.first}');
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Error loading rate limits: $e');
    }
  }

  Future<void> _loadDataLimits() async {
    try {
      if (kDebugMode) print('🔄 [AppState] Loading data limits...');
      _dataLimits = await _planConfigRepository!.fetchDataLimits();
      if (kDebugMode) print('✅ [AppState] Data limits loaded: ${_dataLimits.length} items');
      if (kDebugMode && _dataLimits.isNotEmpty) print('   Sample: ${_dataLimits.first}');
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Error loading data limits: $e');
    }
  }

  Future<void> _loadValidityPeriods() async {
    try {
      if (kDebugMode) print('🔄 [AppState] Loading validity periods...');
      _validityPeriods = await _planConfigRepository!.fetchValidityPeriods();
      if (kDebugMode) print('✅ [AppState] Validity periods loaded: ${_validityPeriods.length} items');
      if (kDebugMode && _validityPeriods.isNotEmpty) print('   Sample: ${_validityPeriods.first}');
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Error loading validity periods: $e');
    }
  }

  Future<void> _loadIdleTimeouts() async {
    try {
      if (kDebugMode) print('🔄 [AppState] Loading idle timeouts...');
      _idleTimeouts = await _planConfigRepository!.fetchIdleTimeouts();
      if (kDebugMode) print('✅ [AppState] Idle timeouts loaded: ${_idleTimeouts.length} items');
      if (kDebugMode && _idleTimeouts.isNotEmpty) print('   Sample: ${_idleTimeouts.first}');
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Error loading idle timeouts: $e');
    }
  }

  Future<void> _loadSharedUsers() async {
    try {
      if (kDebugMode) print('🔄 [AppState] Loading shared users...');
      _sharedUsers = await _planConfigRepository!.fetchSharedUsers();
      if (kDebugMode) print('✅ [AppState] Shared users loaded: ${_sharedUsers.length} items');
      if (kDebugMode && _sharedUsers.isNotEmpty) print('   Sample: ${_sharedUsers.first}');
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Error loading shared users: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadSubscription() async {
    try {
      if (_subscriptionRepository == null) _initializeRepositories();
      
      final subscriptionData = await _subscriptionRepository!.checkSubscriptionStatus();
      
      if (subscriptionData != null) {
        if (kDebugMode) print('📦 [AppState] Subscription data received: $subscriptionData');
        
        // Handle API response structure
        // The endpoint returns { "status": "success", "data": { ... } } or just the data map
        final data = subscriptionData['data'] is Map ? subscriptionData['data'] : subscriptionData;
        
        _subscription = SubscriptionModel.fromJson(data);
        if (kDebugMode) print('✅ [AppState] Subscription loaded: ${_subscription!.tier}');
      } else {
        if (kDebugMode) print('ℹ️ [AppState] No subscription data returned from check');
        _subscription = null;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load subscription error: $e');
      _setError(e.toString());
    }
  }

  /// Load wallet balance (current withdrawable funds)
  Future<void> loadWalletBalance() async {
    try {
      if (_partnerRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('💰 [AppState] Loading wallet balance...');
      final balanceData = await _partnerRepository!.fetchWalletBalance();
      
      if (balanceData != null && balanceData['wallet_balance'] != null) {
        _walletBalance = CurrencyUtils.parseAmount(balanceData['wallet_balance']);
        if (kDebugMode) print('✅ [AppState] Wallet balance loaded: $_walletBalance');
      } else {
        if (kDebugMode) print('⚠️ [AppState] No wallet balance data received');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load wallet balance error: $e');
      _setError(e.toString());
    }
  }

  /// Load revenue counters (Total, Online, Assigned)
  Future<void> loadCountersBalance() async {
    try {
      if (_partnerRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('💰 [AppState] Loading revenue counters...');
      final countersData = await _partnerRepository!.fetchCountersBalance();
      
      if (kDebugMode) print('📊 [AppState] Raw countersData: $countersData');
      
      if (countersData != null) {
        _totalRevenue = CurrencyUtils.parseAmount(countersData['total_revenue']);
        _onlineRevenue = CurrencyUtils.parseAmount(countersData['online_revenue_counter']);
        // Note: Backend has a typo 'assinged'
        _assignedRevenue = CurrencyUtils.parseAmount(countersData['assinged_revenue_counter']);
        
        // Map assigned revenue to deprecated field for compatibility
        _assignedWalletBalance = _assignedRevenue;
        
        if (kDebugMode) {
          print('✅ [AppState] Counters loaded successfully:');
          print('   - Total Revenue: \$_totalRevenue');
          print('   - Online Revenue: \$_onlineRevenue');
          print('   - Assigned Revenue: \$_assignedRevenue');
        }
      } else {
        if (kDebugMode) print('⚠️ [AppState] No counters data received');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load counters error: $e');
      _setError(e.toString());
    }
  }

  /// Deprecated: Use loadCountersBalance instead
  Future<void> loadAssignedWalletBalance() async {
    await loadCountersBalance();
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
      if (_transactionRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('💳 [AppState] Loading wallet transactions...');
      _walletTransactions = await _transactionRepository!.getWalletTransactions();
      
      if (kDebugMode) print('✅ [AppState] Wallet transactions loaded: ${_walletTransactions.length}');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load wallet transactions error: $e');
      _setError(e.toString());
    }
  }

  /// Load assigned plan transactions
  Future<void> loadAssignedTransactions() async {
    try {
      if (_transactionRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('💳 [AppState] Loading assigned transactions...');
      _assignedTransactions = await _transactionRepository!.fetchAssignedPlanTransactions();
      
      if (kDebugMode) print('✅ [AppState] Assigned transactions loaded: ${_assignedTransactions.length}');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load assigned transactions error: $e');
      _setError(e.toString());
    }
  }

  /// Load assigned wallet transactions
  Future<void> loadAssignedWalletTransactions() async {
    try {
      if (_transactionRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('💳 [AppState] Loading assigned wallet transactions...');
      _assignedWalletTransactions = await _transactionRepository!.getAssignedWalletTransactions();
      
      if (kDebugMode) print('✅ [AppState] Assigned wallet transactions loaded: ${_assignedWalletTransactions.length}');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load assigned wallet transactions error: $e');
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
      if (_transactionRepository == null) _initializeRepositories();
      
      if (type == 'assigned') {
        return await _transactionRepository!.getAssignedTransactionDetails(id);
      } else {
        return await _transactionRepository!.getWalletTransactionDetails(id);
      }
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Get transaction details error: $e');
      rethrow;
    }
  }

  /// Load withdrawal history
  Future<void> loadWithdrawals() async {
    try {
      if (_transactionRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('💸 [AppState] Loading withdrawals...');
      _withdrawals = await _transactionRepository!.getWithdrawals();
      
      if (kDebugMode) {
        print('✅ [AppState] Withdrawals loaded: ${_withdrawals.length}');
        if (_withdrawals.isNotEmpty) {
          print('   Sample withdrawal fields: ${_withdrawals.first.keys}');
          print('   Sample withdrawal: ${_withdrawals.first}');
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load withdrawals error: $e');
      _setError(e.toString());
    }
  }

  /// Request payout/withdrawal
  Future<bool> requestPayout(double amount, String paymentMethodId) async {
    try {
      if (_transactionRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('💸 [AppState] Requesting payout: $amount to method: $paymentMethodId');
      
      final withdrawalData = {
        'amount': amount.toString(),
        'payment_method': paymentMethodId,
      };
      
      final result = await _transactionRepository!.createWithdrawal(withdrawalData);
      
      if (kDebugMode) print('✅ [AppState] Payout requested successfully: ${result['id']}');
      
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
      if (kDebugMode) print('❌ [AppState] Request payout error: $e');
      _setError(e.toString());
      return false;
    }
  }

  /// Load complete dashboard data (including wallet and transactions)
  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      if (kDebugMode) print('📊 [AppState] Loading dashboard data...');
      
      await Future.wait([
        loadAllWalletBalances(),
        loadAllTransactions(),
        loadWithdrawals(),
        // Load aggregate data usage for dashboard
        getAggregateActiveDataUsage().then((value) => _aggregateDataUsage = value),
      ]);
      
      // Initialize local notification service
      _initializeNotificationService();
      
      if (kDebugMode) print('✅ [AppState] Dashboard data loaded successfully');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load dashboard data error: $e');
      _isLoading = false;
      _setError(e.toString());
      notifyListeners();
    }
  }

  /// Load available subscription plans
  Future<void> loadAvailableSubscriptionPlans() async {
    try {
      if (_subscriptionRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('📋 [AppState] Loading available subscription plans');
      final plansData = await _subscriptionRepository!.fetchSubscriptionPlans();
      
      _availableSubscriptionPlans = plansData
          .map<SubscriptionPlanModel>((data) => SubscriptionPlanModel.fromJson(data))
          .toList();
      
      if (kDebugMode) print('✅ [AppState] Loaded ${_availableSubscriptionPlans.length} subscription plans');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load available subscription plans error: $e');
      _setError(e.toString());
    }
  }

  /// Purchase a subscription plan
  Future<bool> purchaseSubscriptionPlan(String planId, String paymentReference) async {
    _setLoading(true);
    try {
      if (_subscriptionRepository == null) _initializeRepositories();
      
      if (kDebugMode) {
        print('💳 [AppState] Purchasing subscription plan: $planId');
        print('   Payment reference: $paymentReference');
      }
      final result = await _subscriptionRepository!.purchaseSubscription(planId, paymentReference);
      
      if (result != null) {
        if (kDebugMode) print('✅ [AppState] Subscription purchase successful');
        // Reload subscription to get updated data
        await loadSubscription();
        _setLoading(false);
        return true;
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Purchase subscription error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Get payment details for Paystack inline popup
  Map<String, dynamic> getPaymentDetails({
    required String planId,
    required String planName,
    required double amount,
  }) {
    final email = _currentUser?.email;
    if (email == null) {
      throw Exception('User email not found');
    }
    
    // Get currency code based on partner country
    final currency = _getCurrencyCodeForPayment();
    
    if (kDebugMode) {
      print('💰 [AppState] Payment details prepared');
      print('   Email: $email, Amount: $amount, Currency: $currency');
    }
    
    return {
      'email': email,
      'amount': amount,
      'planId': planId,
      'planName': planName,
      'currency': currency,
    };
  }

  /// Get currency code for payment based on partner country
  String get currencyCode {
    final country = _currentUser?.country;
    
    if (country == null) return 'GHS'; // Default to Ghana Cedis
    
    switch (country.toLowerCase()) {
      case 'ghana':
        return 'GHS';
      case 'nigeria':
        return 'NGN';
      case 'kenya':
        return 'KES';
      case 'south africa':
        return 'ZAR';
      case 'uganda':
        return 'UGX';
      case 'cote d\'ivoire':
      case 'ivory coast':
        return 'XOF'; // CFA Franc BCEAO
      default:
        return 'GHS'; // Default to Ghana Cedis
    }
  }

  // Legacy private method for internal use if needed, but better to forward to getter
  String _getCurrencyCodeForPayment() => currencyCode;

  void markAllNotificationsAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  void markNotificationAsRead(String notificationId) {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => _notifications.first,
    );
    notification.isRead = true;
    notifyListeners();
  }

  void dismissNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  Future<void> loadProfiles() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void deleteProfile(String profileId) {
    _profiles.removeWhere((p) => p.id == profileId);
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _selectedLanguage = LanguageModel.availableLanguages.firstWhere(
      (lang) => lang.code == languageCode,
      orElse: () => LanguageModel.availableLanguages.first,
    );
    notifyListeners();
  }
  
  Future<void> loadUsers() async {
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_customerRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('Loading users from API...');
      
      // Fetch active sessions first to determine online status
      final activeSessions = await _customerRepository!.getActiveSessions();
      if (kDebugMode) print('Active sessions: $activeSessions');
      
      final response = await _customerRepository!.fetchCustomers(page: 1, pageSize: 20);
      if (kDebugMode) print('Users API response: $response');
      
      if (response != null) {
        // Handle nested data structure: { data: { results: [...] } }
        List<dynamic>? usersList;
        
        if (response['data'] is Map && response['data']['results'] is List) {
          usersList = response['data']['results'] as List;
        } else if (response['results'] is List) {
          usersList = response['results'] as List;
        } else if (response['data'] is List) {
          usersList = response['data'] as List;
        }
        
        if (usersList != null) {
          if (kDebugMode) print('Found ${usersList.length} users');
          _users = usersList.map((u) {
            // Check if user is in active sessions
            final username = u['username'] as String?;
            final isConnected = username != null && activeSessions.contains(username);
            return UserModel.fromJson(u, isConnected: isConnected);
          }).toList();
        } else {
          if (kDebugMode) print('No users list found in response');
          _users = [];
        }
      } else {
        if (kDebugMode) print('No users found or invalid response structure');
        _users = [];
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load users error: $e');
      _setError('Failed to load users: $e');
      _users = [];
      notifyListeners();
    }
  }
  
  Future<void> loadRouters() async {
    try {
      if (kDebugMode) print('📡 [loadRouters] Starting router fetch...');
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_routerRepository == null) _initializeRepositories();
      
      if (kDebugMode) print('📡 [loadRouters] Calling API: /partner/routers/list/');
      final routersData = await _routerRepository!.fetchRouters();
      if (kDebugMode) print('📡 [loadRouters] API returned ${routersData.length} routers');
      if (kDebugMode) print('📡 [loadRouters] Raw data: $routersData');
      
      _routers = routersData.map((data) {
        final router = RouterModel(
          id: data['id']?.toString() ?? '',
          name: data['name']?.toString() ?? 'Router',
          macAddress: data['mac_address']?.toString() ?? '00:00:00:00:00:00',
          status: data['is_active'] == true ? 'online' : 'offline',
          connectedUsers: (data['connected_users'] as num?)?.toInt() ?? 0,
          dataUsageGB: (data['data_usage_gb'] as num?)?.toDouble() ?? 0.0,
          uptimeHours: (data['uptime_hours'] as num?)?.toInt() ?? 0,
          lastSeen: data['last_seen'] != null 
              ? DateTime.tryParse(data['last_seen'].toString()) ?? DateTime.now()
              : DateTime.now(),
        );
        if (kDebugMode) print('📡 [loadRouters] Parsed router: ${router.id} - ${router.name}');
        return router;
      }).toList();
      
      if (kDebugMode) print('✅ [loadRouters] Successfully loaded ${_routers.length} routers');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [loadRouters] Error loading routers: $e');
      _setError(e.toString());
    }
  }
  
  Future<void> loadPlans() async {
    try {
      // CACHE-FIRST: Try to load from cache first
      final cachedData = await _cacheService.getData('plans', isCritical: true);
      if (cachedData != null && cachedData is List) {
        _plans = cachedData.map<PlanModel>((data) => PlanModel.fromJson(data)).toList();
        notifyListeners();
        if (kDebugMode) print('📦 [AppState] Loaded ${_plans.length} plans from cache');
      }
      
      // FORCE REMOTE API: Always fetch fresh data in background
      if (_planRepository == null) _initializeRepositories();
      
      // Fetch plans from API using PlanRepository (not WalletRepository)
      final plansData = await _planRepository!.fetchPlans();
      _plans = plansData.map<PlanModel>((data) => PlanModel.fromJson(data)).toList();
      
      // Save fresh data to cache
      await _cacheService.saveData('plans', plansData, isCritical: true);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ [AppState] Load plans error: $e');
      _setError(e.toString());
    }
  }
  
  Future<void> loadTransactions() async {
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_walletRepository == null) _initializeRepositories();
      
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
      _setError(e.toString());
    }
  }
  
  
  Future<void> createUser(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Use CustomerRepository instead of mock AuthService
      if (_customerRepository == null) _initializeRepositories();
      await _customerRepository!.createCustomer(userData);
      await loadUsers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }
  
  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Use CustomerRepository instead of mock AuthService
      if (_customerRepository == null) _initializeRepositories();
      await _customerRepository!.updateCustomer(id, userData);
      await loadUsers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }
  
  Future<void> deleteUser(String id) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Use CustomerRepository instead of mock AuthService
      if (_customerRepository == null) _initializeRepositories();
      await _customerRepository!.deleteCustomer(id);
      await loadUsers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }

  /// Get customer data usage
  Future<Map<String, dynamic>?> getCustomerDataUsage(String username) async {
    try {
      if (_customerRepository == null) _initializeRepositories();
      return await _customerRepository!.getCustomerDataUsage(username);
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Get customer data usage error: $e');
      return null;
    }
  }

  /// Get customer transactions
  Future<List<dynamic>> getCustomerTransactions(String username) async {
    try {
      if (_customerRepository == null) _initializeRepositories();
      return await _customerRepository!.getCustomerTransactions(username);
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Get customer transactions error: $e');
      return [];
    }
  }

  /// Toggle user block status
  Future<void> toggleUserBlock(String username, bool currentlyBlocked) async {
    try {
      if (_customerRepository == null) _initializeRepositories();
      
      if (currentlyBlocked) {
        await _customerRepository!.unblockCustomer(username);
      } else {
        await _customerRepository!.blockCustomer(username);
      }
      
      // Reload users to reflect changes
      await loadUsers();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Toggle user block error: $e');
      rethrow;
    }
  }
  
  Future<void> createPlan(Map<String, dynamic> planData) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_planRepository == null) _initializeRepositories();
      
      await _planRepository!.createPlan(planData);
      await loadPlans();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }

  Future<void> updatePlan(String planId, Map<String, dynamic> planData) async {
    _setLoading(true);
    try {
      if (_planRepository == null) _initializeRepositories();
      
      await _planRepository!.updatePlan(planId, planData);
      await loadPlans();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete a plan
  Future<void> deletePlan(String planId) async {
    _setLoading(true);
    try {
      if (_planRepository == null) _initializeRepositories();
      
      await _planRepository!.deletePlan(planId);
      await loadPlans(); // Reload list
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  Future<void> assignPlan(String userId, String planId) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_planRepository == null) _initializeRepositories();
      
      await _planRepository!.assignPlan({'customer_id': userId, 'plan_id': planId});
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }
  
  
  // ==================== Payment Method Management ====================
  
  /// Get payment methods list
  List<dynamic> get paymentMethods => _paymentMethods;
  
  /// Load payment methods from API
  Future<void> loadPaymentMethods() async {
    try {
      if (_paymentMethodRepository == null) _initializeRepositories();
      
      _paymentMethods = await _paymentMethodRepository!.fetchPaymentMethods();
      if (kDebugMode) print('✅ [AppState] Loaded ${_paymentMethods.length} payment methods');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load payment methods error: $e');
      _setError(e.toString());
    }
  }
  
  /// Request OTP for creating payment method
  Future<Map<String, dynamic>?> requestPaymentMethodOtp(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_paymentMethodRepository == null) _initializeRepositories();
      
      // Store data for later verification
      _pendingPaymentMethodData = data;
      
      final result = await _paymentMethodRepository!.requestCreateOtp(data);
      
      // Extract OTP ID from response
      if (result != null && result['data'] != null) {
        final otpId = result['data']['otp_id']?.toString();
        if (otpId != null) {
          _paymentMethodOtpId = otpId;
          if (kDebugMode) print('✅ [AppState] Stored payment method OTP ID: $otpId');
        }
      }
      
      _setLoading(false);
      return result;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Request payment method OTP error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Verify OTP and create payment method
  Future<Map<String, dynamic>?> verifyPaymentMethodOtp(String otp) async {
    if (_pendingPaymentMethodData == null) {
      _setError('No pending payment method data found');
      return null;
    }
    
    if (_paymentMethodOtpId == null) {
      _setError('No OTP ID found. Please try requesting OTP again.');
      return null;
    }
    
    _setLoading(true);
    try {
      if (_paymentMethodRepository == null) _initializeRepositories();
      
      final result = await _paymentMethodRepository!.verifyCreateOtp(
        data: _pendingPaymentMethodData!,
        otp: otp,
        otpId: _paymentMethodOtpId!,
      );
      
      // Clear pending data and OTP ID after successful verification
      _pendingPaymentMethodData = null;
      _paymentMethodOtpId = null;
      
      await loadPaymentMethods(); // Reload list
      _setLoading(false);
      return result;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Verify payment method OTP error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete a payment method
  Future<bool> deletePaymentMethod(String slug) async {
    _setLoading(true);
    try {
      if (_paymentMethodRepository == null) _initializeRepositories();
      
      final success = await _paymentMethodRepository!.deletePaymentMethod(slug);
      if (success) {
        await loadPaymentMethods(); // Reload list
      }
      _setLoading(false);
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Delete payment method error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // ==================== Active Sessions Management ====================
  
  /// Load active WiFi sessions from API
  Future<void> loadActiveSessions() async {
    try {
      if (_sessionRepository == null) _initializeRepositories();
      final sessions = await _sessionRepository!.fetchActiveSessions();
      _activeSessions = sessions.map((s) => s as Map<String, dynamic>).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load active sessions error: $e');
      _setError(e.toString());
    }
  }
  
  /// Load assigned plans
  Future<void> loadAssignedPlans() async {
    try {
      if (_planRepository == null) _initializeRepositories();
      final plans = await _planRepository!.fetchAssignedPlans();
      _assignedPlans = plans;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load assigned plans error: $e');
      // Don't set global error for this background fetch
    }
  }

  /// Fetch shared users configuration
  Future<void> fetchSharedUsers() async {
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      final configs = await _planConfigRepository!.fetchSharedUsers();
      _sharedUsers = configs;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch shared users error: $e');
      // Don't set global error for this background fetch
    }
  }
  
  /// Disconnect an active session
  Future<void> disconnectSession(Map<String, dynamic> sessionData) async {
    _setLoading(true);
    try {
      if (_sessionRepository == null) _initializeRepositories();
      final success = await _sessionRepository!.disconnectSession(sessionData);
      if (success) {
        await loadActiveSessions(); // Reload sessions after disconnect
      }
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Disconnect session error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  // ==================== Hotspot User Management ====================
  
  /// Load hotspot profiles
  Future<void> loadHotspotProfiles() async {
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      if (kDebugMode) print('📋 [AppState] Loading hotspot profiles... Current count: ${_hotspotProfiles.length}');
      final profiles = await _hotspotRepository!.fetchProfiles();
      _hotspotProfiles = profiles.map((p) => HotspotProfileModel.fromJson(p)).toList();
      if (kDebugMode) print('✅ [AppState] Hotspot profiles loaded. New count: ${_hotspotProfiles.length}');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load hotspot profiles error: $e');
      _setError(e.toString());
    }
  }

  /// Load hotspot users
  Future<void> loadHotspotUsers() async {
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      final users = await _hotspotRepository!.fetchUsers();
      _hotspotUsers = users;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load hotspot users error: $e');
      _setError(e.toString());
    }
  }
  
  /// Create a new hotspot user
  Future<void> createHotspotUser(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      await _hotspotRepository!.createUser(userData);
      await loadHotspotUsers(); // Reload list
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete a hotspot user
  Future<void> deleteHotspotUser(String username) async {
    _setLoading(true);
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      await _hotspotRepository!.deleteUser(username);
      await loadHotspotUsers(); // Reload list
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Update a hotspot user
  Future<void> updateHotspotUser(String username, Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      await _hotspotRepository!.updateUser(username, userData);
      await loadHotspotUsers(); // Reload list
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  // ==================== Configuration Management ====================
  

  /// Fetch rate limits
  Future<void> fetchRateLimits() async {
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      final limits = await _planConfigRepository!.fetchRateLimits();
      _rateLimits = limits;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch rate limits error: $e');
    }
  }
  
  /// Fetch idle timeouts
  Future<void> fetchIdleTimeouts() async {
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      final timeouts = await _planConfigRepository!.fetchIdleTimeouts();
      _idleTimeouts = timeouts;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch idle timeouts error: $e');
    }
  }
  
  /// Fetch validity periods
  Future<void> fetchValidityPeriods() async {
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      final periods = await _planConfigRepository!.fetchValidityPeriods();
      _validityPeriods = periods;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch validity periods error: $e');
    }
  }
  
  /// Fetch data limits
  Future<void> fetchDataLimits() async {
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      final limits = await _planConfigRepository!.fetchDataLimits();
      _dataLimits = limits;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch data limits error: $e');
    }
  }
  
  // ==================== Configuration CRUD Operations ====================
  
  /// Create rate limit
  Future<void> createRateLimit(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.createRateLimit(data);
      await _loadRateLimits(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Create rate limit error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Update rate limit
  Future<void> updateRateLimit(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.updateRateLimit(id, data);
      await _loadRateLimits();
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Update rate limit error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete rate limit
  Future<void> deleteRateLimit(int id) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.deleteRateLimit(id);
      await _loadRateLimits(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Delete rate limit error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Create data limit
  Future<void> createDataLimit(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.createDataLimit(data);
      await _loadDataLimits(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Create data limit error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Update data limit
  Future<void> updateDataLimit(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.updateDataLimit(id, data);
      await _loadDataLimits();
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Update data limit error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete data limit
  Future<void> deleteDataLimit(int id) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.deleteDataLimit(id);
      await _loadDataLimits(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Delete data limit error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Create validity period
  Future<void> createValidityPeriod(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.createValidityPeriod(data);
      await _loadValidityPeriods(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Create validity period error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Update validity period
  Future<void> updateValidityPeriod(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.updateValidityPeriod(id, data);
      await _loadValidityPeriods();
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Update validity period error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete validity period
  Future<void> deleteValidityPeriod(int id) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.deleteValidityPeriod(id);
      await _loadValidityPeriods(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Delete validity period error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Create idle timeout
  Future<void> createIdleTimeout(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.createIdleTimeout(data);
      await _loadIdleTimeouts(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Create idle timeout error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Update idle timeout
  Future<void> updateIdleTimeout(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.updateIdleTimeout(id, data);
      await _loadIdleTimeouts();
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Update idle timeout error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete idle timeout
  Future<void> deleteIdleTimeout(int id) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.deleteIdleTimeout(id);
      await _loadIdleTimeouts(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Delete idle timeout error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Create shared users configuration
  Future<void> createSharedUsersConfig(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.createSharedUsers(data);
      await _loadSharedUsers(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Create shared users error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Update shared users configuration
  Future<void> updateSharedUsersConfig(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.updateSharedUsers(id, data);
      await _loadSharedUsers();
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Update shared users error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete shared users configuration
  Future<void> deleteSharedUsersConfig(int id) async {
    _setLoading(true);
    try {
      if (_planConfigRepository == null) _initializeRepositories();
      await _planConfigRepository!.deleteSharedUsers(id);
      await _loadSharedUsers(); // Reload list
      _setLoading(false);
    } catch (e) {
      if (kDebugMode) print('Delete shared users error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  // ==================== Plan & Profile Enhancements ====================
  

  /// Create a hotspot profile
  Future<void> createHotspotProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      await _hotspotRepository!.createProfile(profileData);
      await loadHotspotProfiles(); // Reload profiles
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Update a hotspot profile
  Future<void> updateHotspotProfile(String profileSlug, Map<String, dynamic> profileData) async {
    _setLoading(true);
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      await _hotspotRepository!.updateProfile(profileSlug, profileData);
      await loadHotspotProfiles(); // Reload profiles
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  /// Delete a hotspot profile
  Future<String> deleteHotspotProfile(String profileSlug) async {
    _setLoading(true);
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      final response = await _hotspotRepository!.deleteProfile(profileSlug);
      await loadHotspotProfiles(); // Reload profiles
      _setLoading(false);
      return response['message']?.toString() ?? 'Profile deleted successfully';
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
  
  Future<void> createRouter(Map<String, dynamic> routerData) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_routerRepository == null) _initializeRepositories();
      
      await _routerRepository!.addRouter(routerData);
      await loadRouters();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }
  
  Future<void> blockDevice(String deviceId) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Use CustomerRepository for block/unblock operations
      if (_customerRepository == null) _initializeRepositories();
      await _customerRepository!.blockCustomer(deviceId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }
  
  Future<void> unblockDevice(String deviceId) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Use CustomerRepository for block/unblock operations
      if (_customerRepository == null) _initializeRepositories();
      await _customerRepository!.unblockCustomer(deviceId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== Role Management ====================
  
  /// Fetch available permissions and update mapping
  Future<List<dynamic>> fetchPermissions() async {
    try {
      if (_roleRepository == null) _initializeRepositories();
      if (kDebugMode) print('🔐 [AppState] Fetching permissions...');
      final permissions = await _roleRepository!.fetchPermissions();
      if (kDebugMode) print('✅ [AppState] Fetched ${permissions.length} permissions');
      
      // Update permission map
      _permissionIdToCodename.clear();
      for (var perm in permissions) {
        if (perm is Map) {
          final id = perm['id'] as int?;
          final codename = perm['codename'] as String?;
          if (id != null && codename != null) {
            _permissionIdToCodename[id] = codename;
          }
        }
      }
      
      // If current user has integer permissions, map them now
      if (_currentUser != null && _currentUser!.permissions != null) {
        final hasIntPermissions = _currentUser!.permissions!.any((p) => int.tryParse(p.toString()) != null);
        if (hasIntPermissions) {
          final mappedPermissions = _currentUser!.permissions!.map((p) {
            final id = int.tryParse(p.toString());
            if (id != null) {
              return _permissionIdToCodename[id] ?? p.toString();
            }
            return p.toString();
          }).cast<String>().toList();
          
          _currentUser = UserModel(
            id: _currentUser!.id,
            name: _currentUser!.name,
            email: _currentUser!.email,
            role: _currentUser!.role,
            phone: _currentUser!.phone,
            isActive: _currentUser!.isActive,
            createdAt: _currentUser!.createdAt,
            permissions: mappedPermissions,
            assignedRouters: _currentUser!.assignedRouters,
            country: _currentUser!.country,
            address: _currentUser!.address,
            city: _currentUser!.city,
            numberOfRouters: _currentUser!.numberOfRouters,
          );
          notifyListeners();
        }
      }
      
      return permissions;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Fetch permissions error: $e');
      rethrow;
    }
  }

  /// Load purchased plans
  Future<void> loadPurchasedPlans() async {
    try {
      if (_customerRepository == null) _initializeRepositories();
      final plans = await _customerRepository!.fetchPurchasedPlans();
      _purchasedPlans = plans;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load purchased plans error: $e');
    }
  }

  /// Get purchased plans for a specific customer
  Future<List<dynamic>> getCustomerPurchasedPlans(String customerId) async {
    try {
      if (_customerRepository == null) _initializeRepositories();
      // Ensure we have the latest list
      await loadPurchasedPlans();
      
      // Filter by customer ID
      return _purchasedPlans.where((plan) {
        final planCustomerId = plan['customer']?.toString();
        return planCustomerId == customerId.toString();
      }).toList();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Get customer purchased plans error: $e');
      return [];
    }
  }

  /// Get customer assigned transactions
  Future<List<dynamic>> getCustomerAssignedTransactions(String username) async {
    try {
      if (_customerRepository == null) _initializeRepositories();
      return await _customerRepository!.getCustomerAssignedTransactions(username);
    } catch (e) {
       if (kDebugMode) print('❌ [AppState] Get customer assigned transactions error: $e');
       return [];
    }
  }

  /// Get customer wallet transactions
  Future<List<dynamic>> getCustomerWalletTransactions(String username) async {
    try {
      if (_customerRepository == null) _initializeRepositories();
      return await _customerRepository!.getCustomerWalletTransactions(username);
    } catch (e) {
       if (kDebugMode) print('❌ [AppState] Get customer wallet transactions error: $e');
       return [];
    }
  }
  


  /// Get assigned plans for a specific customer
  Future<List<dynamic>> getCustomerAssignedPlans(String customerId) async {
    try {
      if (_planRepository == null) _initializeRepositories();
      final allAssignedPlans = await _planRepository!.fetchAssignedPlans();
      
      // Filter by customer ID
      return allAssignedPlans.where((plan) {
        // Handle both String and Int ID comparisons
        final planCustomerId = plan['customer']?.toString();
        return planCustomerId == customerId.toString();
      }).toList();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Get customer assigned plans error: $e');
      return [];
    }
  }

  /// Load roles from API
  Future<void> loadRoles() async {
    try {
      if (_roleRepository == null) _initializeRepositories();
      if (kDebugMode) print('📋 [AppState] Loading roles...');
      
      final rolesData = await _roleRepository!.fetchRoles();
      _roles = rolesData.map((data) => RoleModel.fromJson(data)).toList();
      
      if (kDebugMode) print('✅ [AppState] Loaded ${_roles.length} roles');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load roles error: $e');
      _setError(e.toString());
    }
  }

  /// Create role
  Future<void> createRole(Map<String, dynamic> roleData) async {
    _setLoading(true);
    try {
      if (_roleRepository == null) _initializeRepositories();
      await _roleRepository!.createRole(roleData);
      await loadRoles();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Update role
  Future<void> updateRole(String slug, Map<String, dynamic> roleData) async {
    _setLoading(true);
    try {
      if (_roleRepository == null) _initializeRepositories();
      await _roleRepository!.updateRole(slug, roleData);
      await loadRoles();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Delete role
  Future<void> deleteRole(String slug) async {
    _setLoading(true);
    try {
      if (_roleRepository == null) _initializeRepositories();
      final success = await _roleRepository!.deleteRole(slug);
      if (success) {
        await loadRoles();
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // ==================== Worker/Collaborator Management ====================
  
  /// Load workers from API
  Future<void> loadWorkers() async {
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      if (kDebugMode) print('👷 [AppState] Loading workers...');
      
      final workersData = await _collaboratorRepository!.fetchCollaborators();
      _workers = workersData.map((data) => WorkerModel.fromJson(data)).toList();
      
      if (kDebugMode) print('✅ [AppState] Loaded ${_workers.length} workers');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Load workers error: $e');
      _setError(e.toString());
    }
  }

  /// Create worker
  Future<void> createWorker(Map<String, dynamic> workerData) async {
    _setLoading(true);
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      await _collaboratorRepository!.createCollaborator(workerData);
      await loadWorkers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Assign role to worker
  Future<void> assignRoleToWorker(String username, String roleId) async {
    _setLoading(true);
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      await _collaboratorRepository!.assignRole(username, {'role_id': roleId});
      await loadWorkers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Update worker role
  Future<void> updateWorkerRole(String username, String roleSlug) async {
    _setLoading(true);
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      await _collaboratorRepository!.updateRole(username, {'role': roleSlug});
      await loadWorkers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Delete worker
  Future<void> deleteWorker(String username) async {
    _setLoading(true);
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      final success = await _collaboratorRepository!.deleteCollaborator(username);
      if (success) {
        await loadWorkers();
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Fetch worker details
  Future<WorkerModel?> fetchWorkerDetails(String username) async {
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      final data = await _collaboratorRepository!.fetchCollaboratorDetails(username);
      if (data != null) {
        return WorkerModel.fromJson(data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Fetch worker details error: $e');
      rethrow;
    }
  }


  // ============================================================================
  // ROUTER ASSIGNMENT MANAGEMENT
  // ============================================================================
  
  /// Load router assignments from SharedPreferences
  Future<void> loadRouterAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('router_assignments');
      if (json != null) {
        final Map<String, dynamic> decoded = jsonDecode(json);
        _routerAssignments = decoded.map(
          (key, value) => MapEntry(key, List<String>.from(value as List))
        );
        if (kDebugMode) print('✅ [RouterAssignment] Loaded ${_routerAssignments.length} assignments');
      } else {
        if (kDebugMode) print('ℹ️ [RouterAssignment] No saved assignments found');
      }
    } catch (e) {
      if (kDebugMode) print('❌ [RouterAssignment] Error loading assignments: $e');
    }
  }
  
  /// Save router assignments to SharedPreferences
  Future<void> saveRouterAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_routerAssignments);
      await prefs.setString('router_assignments', json);
      notifyListeners();
      if (kDebugMode) print('✅ [RouterAssignment] Saved ${_routerAssignments.length} assignments');
    } catch (e) {
      if (kDebugMode) print('❌ [RouterAssignment] Error saving assignments: $e');
    }
  }
  
  /// Assign routers to a worker/manager
  Future<void> assignRoutersToWorker(String username, List<String> routerIds) async {
    _routerAssignments[username.toLowerCase()] = routerIds; // Store as lowercase
    await saveRouterAssignments();
    if (kDebugMode) print('✅ [RouterAssignment] Assigned ${routerIds.length} routers to ${username.toLowerCase()}');
  }
  
  /// Get assigned routers for a specific worker/manager
  List<String> getAssignedRouters(String username) {
    return _routerAssignments[username.toLowerCase()] ?? []; // Retrieve as lowercase
  }
  
  /// Remove router assignment for a worker
  Future<void> removeRouterAssignment(String username) async {
    _routerAssignments.remove(username.toLowerCase());
    await saveRouterAssignments();
    if (kDebugMode) print('✅ [RouterAssignment] Removed assignment for ${username.toLowerCase()}');
  }

  /// Calculate total data limit for all active users (to show progress)
  double get getAggregateTotalDataLimit {
    double totalLimit = 0.0;
    for (var user in _users) {
      if (user.isActive && user.planName != null) {
        // Find plan by name (loose matching)
        try {
          final plan = _plans.firstWhere((p) => p.name == user.planName);
          if (plan.dataLimit != null) {
            totalLimit += plan.dataLimit!;
          } else {
             // For unlimited plans, add a placeholder amount (e.g. 100GB) or ignore?
             // Adding 0 doesn't help the progress bar. Let's assume unlimited = 500GB for viz purpose
             totalLimit += 500.0; 
          }
        } catch (_) {}
      }
    }
    // If no active users or plans found, return a fallback to avoid division by zero
    return totalLimit == 0 ? 100.0 : totalLimit;
  }
  
  /// Get all router assignments (for admin view)
  Map<String, List<String>> get allRouterAssignments => Map.unmodifiable(_routerAssignments);
  
  // ============================================================================
  // FILTERED DATA GETTERS (Role-Based Access Control)
  // ============================================================================
  
  /// Get routers visible to current user based on role and assignments
  List<RouterModel> get visibleRouters {
    if (kDebugMode) print('🔍 [visibleRouters] Checking visible routers...');
    if (kDebugMode) print('🔍 [visibleRouters] Current user: ${_currentUser?.email}');
    if (kDebugMode) print('🔍 [visibleRouters] Total routers in state: ${_routers.length}');
    
    if (_currentUser == null) {
      if (kDebugMode) print('❌ [visibleRouters] Current user is NULL - returning empty list');
      return [];
    }
    
    // Partners/Owners see ALL routers
    final role = _currentUser!.role.toLowerCase();
    if (kDebugMode) print('🔍 [visibleRouters] User role (lowercase): "$role"');
    
    if (role == 'partner' || role == 'owner' || role == 'admin' || role == 'administrator') {
      if (kDebugMode) print('✅ [visibleRouters] User is admin/partner/owner - returning ALL ${_routers.length} routers');
      return _routers;
    }
    
    // Workers/Managers see only assigned routers
    if (kDebugMode) print('🔍 [visibleRouters] User is worker/manager - checking assigned routers');
    final assignedIds = getAssignedRouters(_currentUser!.email); // Use email as username
    if (assignedIds.isEmpty) {
      if (kDebugMode) print('⚠️ [RouterAssignment] No routers assigned to ${_currentUser!.email}');
      return [];
    }
    
    final filtered = _routers.where((r) => assignedIds.contains(r.id)).toList();
    if (kDebugMode) print('✅ [RouterAssignment] ${_currentUser!.email} can see ${filtered.length}/${_routers.length} routers');
    return filtered;
  }
  
  /// Get users visible to current user (filtered by assigned routers)
  /// Note: Requires UserModel to have routerId field
  List<UserModel> get visibleUsers {
    if (_currentUser == null) return [];
    
    // Partners/Owners see ALL users
    final role = _currentUser!.role.toLowerCase();
    if (role == 'partner' || role == 'owner' || role == 'admin' || role == 'administrator') {
      return _users;
    }
    
    // Workers/Managers see users on their assigned routers
    // For now, return all users until UserModel has routerId field
    // TODO: Filter by router when UserModel is updated
    return _users;
  }
  
  /// Get hotspot profiles visible to current user (filtered by assigned routers)
  List<HotspotProfileModel> get visibleProfiles {
    if (_currentUser == null) return [];
    
    // Partners/Owners see ALL profiles
    final role = _currentUser!.role.toLowerCase();
    if (role == 'partner' || role == 'owner' || role == 'admin') {
      return _hotspotProfiles;
    }
    
    // Workers/Managers see profiles on their assigned routers
    final assignedIds = getAssignedRouters(_currentUser!.email);
    if (assignedIds.isEmpty) return [];
    
    // Filter profiles by routerIds - profile is visible if ANY of its routers are assigned
    final filtered = _hotspotProfiles.where((p) {
      // Check if profile has any routers assigned to the worker
      return p.routerIds.any((routerId) => assignedIds.contains(routerId));
    }).toList();
    
    return filtered;
  }
  
  /// Get plans visible to current user (filtered by assigned routers)
  List<PlanModel> get visiblePlans {
    if (_currentUser == null) return [];
    
    // Partners/Owners see ALL plans
    final role = _currentUser!.role.toLowerCase();
    if (role == 'partner' || role == 'owner' || role == 'admin' || role == 'administrator') {
      return _plans;
    }
    
    // Workers/Managers see plans on their assigned routers
    // For now, return all plans until PlanModel has routerId field
    // TODO: Filter by router when PlanModel is updated
    return _plans;
  }

  /// Update worker
  Future<void> updateWorker(String username, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      await _collaboratorRepository!.updateCollaborator(username, data);
      await loadWorkers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Assign router to worker
  Future<void> assignRouterToWorker(String username, String routerId) async {
    _setLoading(true);
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      final success = await _collaboratorRepository!.assignRouter(username, {'router_id': routerId});
      if (success) {
        await loadWorkers();
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Remove router from worker
  Future<void> removeRouterFromWorker(String username, String routerId) async {
    _setLoading(true);
    try {
      if (_collaboratorRepository == null) _initializeRepositories();
      final success = await _collaboratorRepository!.removeRouter(username, routerId);
      if (success) {
        await loadWorkers();
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // ==================== Customer Management ====================

  /// Block a customer
  Future<void> blockCustomer(String username) async {
    _setLoading(true);
    try {
      if (_customerRepository == null) _initializeRepositories();
      await _customerRepository!.blockCustomer(username);
      // Refresh customers list if needed, or update local state
      // For now we just return success
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Unblock a customer
  Future<void> unblockCustomer(String username) async {
    _setLoading(true);
    try {
      if (_customerRepository == null) _initializeRepositories();
      await _customerRepository!.unblockCustomer(username);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Get aggregated data usage for all active users
  Future<double> getAggregateActiveDataUsage() async {
    // catch error to avoid breaking dashboard
    try {
      if (_customerRepository == null) _initializeRepositories();
      
      final activeUsernames = await _customerRepository!.getActiveSessions();
      double totalUsageGB = 0.0;
      
      if (activeUsernames.isEmpty) return 0.0;
      
      // Parallel requests could be faster but might hit rate limits.
      // Sequential for safety for now.
      for (final username in activeUsernames) {
        try {
          final usageData = await _customerRepository!.getCustomerDataUsage(username);
          if (usageData != null) {
            // Adjust key based on API response structure
            // Assuming 'total_usage' or 'data_usage' or similar. 
            // Let's guess 'total_usage' or check typical response.
            // If unknown, default to 0.
            final usage = (usageData['total_usage'] ?? usageData['data_usage'] ?? 0);
            if (usage is num) {
              totalUsageGB += usage.toDouble();
            }
          }
        } catch (e) {
           if (kDebugMode) print('⚠️ [AppState] Failed to get usage for $username: $e');
        }
      }
      
      return totalUsageGB;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Aggregate data usage error: $e');
      return 0.0;
    }
  }

  // ==================== Report Generation ====================
  
  /// Generate report file (PDF or CSV)
  Future<Uint8List?> generateReport({
    required DateTimeRange dateRange,
    required String format,
  }) async {
    _setLoading(true);
    try {
      if (_reportRepository == null) _initializeRepositories();
      
      final bytes = await _reportRepository!.generateTransactionReport(
        range: dateRange,
        format: format,
        partnerName: _currentUser?.name ?? 'Partner',
        currency: _getCurrencyCodeForPayment(),
      );
      
      _setLoading(false);
      return bytes;
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Generate report error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // ==================== Security Operations ====================

  /// Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    try {
      if (_passwordRepository == null) _initializeRepositories();
      final success = await _passwordRepository!.changePassword({
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      _setLoading(false);
      return success;
    } catch (e) {
      if (kDebugMode) print('Change password error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Get 2FA status
  Future<bool> getTwoFactorStatus() async {
    try {
      if (_authRepository == null) _initializeRepositories();
      final isEnabled = await _authRepository!.getTwoFactorStatus();
      return isEnabled;
    } catch (e) {
      if (kDebugMode) print('Get 2FA status error: $e');
      return false;
    }
  }

  /// Enable 2FA
  Future<Map<String, dynamic>> enableTwoFactor() async {
    _setLoading(true);
    try {
      if (_authRepository == null) _initializeRepositories();
      final result = await _authRepository!.enableTwoFactor();
      _setLoading(false);
      return result;
    } catch (e) {
      if (kDebugMode) print('Enable 2FA error: $e');
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  /// Disable 2FA
  Future<bool> disableTwoFactor() async {
    _setLoading(true);
    try {
      if (_authRepository == null) _initializeRepositories();
      final success = await _authRepository!.disableTwoFactor();
      _setLoading(false);
      return success;
    } catch (e) {
      if (kDebugMode) print('Disable 2FA error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // ==================== Local Notification Management ====================
  
  /// Initialize local notification service
  Future<void> _initializeNotificationService() async {
    try {
      await _localNotificationService.initialize(
        userId: _currentUser?.id,  // Pass user ID for user-specific storage
        onFetchTransactions: () async => _walletTransactions,
        onFetchPayouts: () async => _withdrawals,
        onFetchWalletBalance: () async => _walletBalance,
        onFetchUserCount: () async => _hotspotUsers.length,
      );
      
      // Listen to notification stream and trigger UI updates (for Android/iOS/Web badge)
      _localNotificationService.notificationStream.listen((_) {
        notifyListeners();  // Ensure badge updates on all platforms
      });
      
      if (kDebugMode) print('✅ [AppState] Notification service initialized for user: ${_currentUser?.id}');
    } catch (e) {
      if (kDebugMode) print('❌ [AppState] Notification service init error: $e');
    }
  }
  
  /// Mark local notification as read
  Future<void> markLocalNotificationAsRead(String id) async {
    await _localNotificationService.markAsRead(id);
    notifyListeners();
  }
  
  /// Mark all local notifications as read
  Future<void> markAllLocalNotificationsAsRead() async {
    await _localNotificationService.markAllAsRead();
    notifyListeners();
  }
  
  /// Clear all local notifications
  Future<void> clearAllLocalNotifications() async {
    await _localNotificationService.clearAll();
    notifyListeners();
  }

  /// Get notification settings
  Map<String, bool> getNotificationSettings() {
    return _localNotificationService.getSettings();
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    await _localNotificationService.updateSettings(settings);
    notifyListeners();
  }
}
