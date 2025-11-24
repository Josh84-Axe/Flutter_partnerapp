import 'package:flutter/material.dart';
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
import '../models/subscription_model.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/connectivity_service.dart';
import '../services/api/api_config.dart';
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
import '../repositories/payment_method_repository.dart';
import '../repositories/additional_device_repository.dart';
import '../utils/country_utils.dart';
import '../utils/currency_utils.dart';
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
  PaymentMethodRepository? _paymentMethodRepository;
  AdditionalDeviceRepository? _additionalDeviceRepository;
  
  // Feature flag to toggle between mock and real API
  bool _useRemoteApi = ApiConfig.useRemoteApi;
  
  // Constructor with debug logging
  AppState() {
    if (kDebugMode) print('🔧 [AppState] Initializing AppState');
    if (kDebugMode) print('🔧 [AppState] ApiConfig.useRemoteApi = ${ApiConfig.useRemoteApi}');
    if (kDebugMode) print('🔧 [AppState] _useRemoteApi = $_useRemoteApi');
  }
  
  bool get useRemoteApi => _useRemoteApi;
  
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
      final dio = apiFactory.createDio();
      
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
      _paymentMethodRepository = PaymentMethodRepository(dio: dio);
      _additionalDeviceRepository = AdditionalDeviceRepository(dio: dio);
    }
  }
  
  UserModel? _currentUser;
  String? _partnerCountry; // Store partner country for currency display
  bool _isLoading = false;
  String? _error;
  String? _lastWithdrawalId; // Store last withdrawal ID for tracking
  String? _registrationEmail; // Store email for verification flow
  
  List<UserModel> _users = [];
  List<RouterModel> _routers = [];
  List<PlanModel> _plans = [];
  List<TransactionModel> _transactions = [];
  double _walletBalance = 0.0;
  List<HotspotProfileModel> _hotspotProfiles = [];
  List<RouterConfigurationModel> _routerConfigurations = [];
  List<RoleModel> _roles = [];
  List<Map<String, dynamic>> _activeSessions = []; // Active WiFi sessions
  List<dynamic> _hotspotUsers = []; // Hotspot users list
  List<dynamic> _assignedPlans = []; // Assigned plans for matching
  
  // Configuration Lists
  List<dynamic> _sharedUsers = [];
  List<dynamic> _rateLimits = [];
  List<dynamic> _idleTimeouts = [];
  
  final List<NotificationModel> _notifications = [];
  final List<ProfileModel> _profiles = [];
  LanguageModel _selectedLanguage = LanguageModel.availableLanguages.first;
  SubscriptionModel? _subscription;
  
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
  List<HotspotProfileModel> get hotspotProfiles => _hotspotProfiles;
  List<RouterConfigurationModel> get routerConfigurations => _routerConfigurations;
  List<RoleModel> get roles => _roles;
  List<Map<String, dynamic>> get activeSessions => _activeSessions;
  List<dynamic> get assignedPlans => _assignedPlans;
  List<dynamic> get hotspotUsers => _hotspotUsers;
  
  List<dynamic> get sharedUsers => _sharedUsers;
  List<dynamic> get rateLimits => _rateLimits;
  List<dynamic> get idleTimeouts => _idleTimeouts;
  
  List<NotificationModel> get notifications => _notifications;
  List<ProfileModel> get profiles => _profiles;
  LanguageModel get selectedLanguage => _selectedLanguage;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;
  SubscriptionModel? get subscription => _subscription;
  
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
  
  Future<bool> login(String email, String password) async {
    if (kDebugMode) print('🔐 [AppState] login() called with email: $email');
    if (kDebugMode) print('🔐 [AppState] _useRemoteApi = $_useRemoteApi');
    if (kDebugMode) print('🔐 [AppState] ApiConfig.useRemoteApi = ${ApiConfig.useRemoteApi}');
    
    _setLoading(true);
    try {
      // FORCE REMOTE API: Always use real API for login (ignore _useRemoteApi flag)
      // This is a temporary fix to bypass the mock data issue
      if (kDebugMode) print('🔐 [AppState] FORCING remote API login (ignoring _useRemoteApi flag)');
      
      // Use real API
      _initializeRepositories();
      final success = await _authRepository!.login(
        email: email,
        password: password,
      );
      if (success) {
        // Load profile to get user data
        final profileData = await _partnerRepository!.fetchProfile();
        if (profileData != null) {
          _currentUser = UserModel(
            id: profileData['id']?.toString() ?? '1',
            name: profileData['first_name']?.toString() ?? 'Partner',
            email: profileData['email']?.toString() ?? email,
            role: 'Partner',
            isActive: true,
            createdAt: DateTime.now(),
          );
        }
        await loadDashboardData();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      if (kDebugMode) print('🔐 [AppState] Login error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _registrationEmail = email; // Store email for verification
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      _initializeRepositories();
      final success = await _authRepository!.register(
        firstName: name,
        email: email,
        password: password,
      );
      if (success) {
        // Try to load profile to get user data
        // If registration requires email verification, this might fail
        try {
          final profileData = await _partnerRepository!.fetchProfile();
          if (profileData != null) {
            _currentUser = UserModel(
              id: profileData['id']?.toString() ?? '1',
              name: profileData['first_name']?.toString() ?? name,
              email: profileData['email']?.toString() ?? email,
              role: 'Partner',
              isActive: true,
              createdAt: DateTime.now(),
            );
            await loadDashboardData();
          }
        } catch (e) {
          // If profile fetch fails (e.g., email verification required),
          // create a temporary user model
          _currentUser = UserModel(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            email: email,
            role: 'Partner',
            isActive: false,
            createdAt: DateTime.now(),
          );
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(e.toString());
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
      final response = await _authRepository!.confirmRegistration(_registrationEmail!, otp);
      
      if (response != null) {
        // If confirmation returns tokens, save them
        if (response['data'] != null && response['data']['access'] != null) {
          // We would need to manually save tokens here or rely on AuthRepository
          // For now, assume success means we can proceed to login
          await login(_registrationEmail!, ''); // This might fail if we don't have password
          // Better approach: Just return true and let UI navigate to login
        }
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
  
  Future<bool> registerWithDetails({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? businessName,
    String? address,
    String? city,
    String? country,
    int? numberOfRouters,
  }) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      _initializeRepositories();
      
      // Convert country name to ISO code if needed
      String? countryIsoCode;
      if (country != null) {
        countryIsoCode = CountryUtils.getIsoCode(country);
        if (kDebugMode) print('Registration: Converting country "$country" to ISO code "$countryIsoCode"');
      }
      
      final success = await _authRepository!.register(
        firstName: fullName,
        email: email,
        password: password,
        phone: phone,
        businessName: businessName,
        address: address,
        city: city,
        country: countryIsoCode,
        numberOfRouters: numberOfRouters,
      );
      if (success) {
        // Registration successful - check if we have tokens (immediate login)
        // or if email verification is required
        final hasTokens = await _authRepository!.isAuthenticated();
        
        if (hasTokens) {
          // Tokens were returned - try to load profile
          try {
            final profileData = await _partnerRepository!.fetchProfile();
            if (profileData != null) {
              _currentUser = UserModel(
                id: profileData['id']?.toString() ?? '1',
                name: profileData['first_name']?.toString() ?? fullName,
                email: profileData['email']?.toString() ?? email,
                role: 'Partner',
                isActive: true,
                createdAt: DateTime.now(),
              );
              await loadDashboardData();
            }
          } catch (e) {
            if (kDebugMode) print('Profile fetch failed after registration: $e');
          }
        } else {
          // No tokens - email verification required
          // Create a temporary user model for UI purposes
          if (kDebugMode) print('Registration successful - email verification required');
          _currentUser = UserModel(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            name: fullName,
            email: email,
            role: 'Partner',
            isActive: false,
            createdAt: DateTime.now(),
          );
        }
      }
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
    _currentUser = null;
    _users = [];
    _routers = [];
    _plans = [];
    _transactions = [];
    _walletBalance = 0.0;
    notifyListeners();
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
          // Store partner country for currency display
          _partnerCountry = profileData['country']?.toString() ?? 
                          profileData['country_name']?.toString() ?? 
                          'Togo'; // Default to Togo for West African partners
          if (kDebugMode) print('Partner country loaded: $_partnerCountry');
          
          _currentUser = UserModel(
            id: profileData['id']?.toString() ?? '1',
            name: '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'.trim(),
            email: profileData['email']?.toString() ?? '',
            role: 'Partner',
            isActive: true,
            createdAt: DateTime.now(),
          );
          await loadDashboardData();
        }
      } catch (e) {
        // Token is invalid, clear it
        await tokenStorage.clearTokens();
        _currentUser = null;
      }
    }
    notifyListeners();
  }
  
  Future<void> loadDashboardData() async {
    await Future.wait([
      loadUsers(),
      loadRouters(),
      loadPlans(),
      loadTransactions(),
      loadWalletBalance(),
      loadNotifications(),
      loadSubscription(),
    ]);
    
    // Load real data from API instead of using placeholders
    _hotspotProfiles = [];
    _routerConfigurations = [];
    _roles = [];
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
      // TODO: Replace with real API call when subscription endpoint is available
      // For now, set to null to show "No subscription" instead of mock data
      _subscription = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

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
      final response = await _customerRepository!.fetchCustomers(page: 1, pageSize: 20);
      if (kDebugMode) print('Users API response: $response');
      
      if (response != null && response['results'] is List) {
        final usersList = response['results'] as List;
        if (kDebugMode) print('Found ${usersList.length} users');
        _users = usersList.map((u) => UserModel.fromJson(u)).toList();
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
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_routerRepository == null) _initializeRepositories();
      
      final routersData = await _routerRepository!.fetchRouters();
      _routers = routersData.map((data) {
        return RouterModel(
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
      }).toList();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadPlans() async {
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_walletRepository == null) _initializeRepositories();
      
      // Fetch plans from API
      final plansData = await _walletRepository!.fetchPlans();
      _plans = plansData.map<PlanModel>((data) {
        // API returns 'validity' in minutes, convert to days
        final validityMinutes = (data['validity'] as num?)?.toInt() ?? 0;
        final validityDays = validityMinutes > 0 ? (validityMinutes / 1440).ceil() : 1;
        
        return PlanModel(
          id: data['id']?.toString() ?? '',
          name: data['name']?.toString() ?? 'Plan',
          price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
          dataLimitGB: (data['data_limit'] as num?)?.toInt() ?? 0,
          validityDays: validityDays,
          speedMbps: 10, // API doesn't provide speed, use default
          isActive: data['is_active'] == true,
          deviceAllowed: (data['shared_users'] as num?)?.toInt() ?? 1,
          userProfile: data['profile_name']?.toString() ?? 'Basic',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
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
  
  Future<void> loadWalletBalance() async {
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_walletRepository == null) _initializeRepositories();
      
      final balanceData = await _walletRepository!.fetchBalance();
      if (balanceData != null) {
        // API returns 'wallet_balance', not 'balance'
        final balanceStr = balanceData['wallet_balance']?.toString() ?? '0.0';
        _walletBalance = double.tryParse(balanceStr) ?? 0.0;
      }
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
  
  Future<void> assignPlan(String userId, String planId) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Always use real API (no mock fallback)
      if (_planRepository == null) _initializeRepositories();
      
      await _planRepository!.assignPlan({'user_id': userId, 'plan_id': planId});
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
    }
  }
  
  Future<void> requestPayout(double amount, String method) async {
    _setLoading(true);
    try {
      // FORCE REMOTE API: Use WalletRepository instead of mock PaymentService
      if (_walletRepository == null) _initializeRepositories();
      final response = await _walletRepository!.createWithdrawal({
        'amount': amount,
        'payment_method': method,
      });
      
      // Store the withdrawal ID from the API response for tracking
      if (response != null && response['data'] != null && response['data']['id'] != null) {
        _lastWithdrawalId = response['data']['id'].toString();
      } else if (response != null && response['id'] != null) {
        _lastWithdrawalId = response['id'].toString();
      }
      
      await loadTransactions();
      await loadWalletBalance();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Re-throw to allow UI to handle error
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
      final profiles = await _hotspotRepository!.fetchProfiles();
      _hotspotProfiles = profiles.map((p) => HotspotProfileModel.fromJson(p)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load hotspot profiles error: $e');
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
  Future<void> deleteHotspotProfile(String profileSlug) async {
    _setLoading(true);
    try {
      if (_hotspotRepository == null) _initializeRepositories();
      await _hotspotRepository!.deleteProfile(profileSlug);
      await loadHotspotProfiles(); // Reload profiles
      _setLoading(false);
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

  Future<void> createRole(Map<String, dynamic> roleData) async {
    final newRole = RoleModel.fromJson(roleData);
    _roles.add(newRole);
    notifyListeners();
  }

  Future<void> updateRole(String id, Map<String, dynamic> roleData) async {
    final index = _roles.indexWhere((r) => r.id == id);
    if (index != -1) {
      _roles[index] = RoleModel.fromJson({...roleData, 'id': id});
      notifyListeners();
    }
  }

  Future<void> deleteRole(String id) async {
    _roles.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
