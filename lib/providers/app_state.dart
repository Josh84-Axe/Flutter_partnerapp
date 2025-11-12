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

class AppState with ChangeNotifier {
  // Legacy mock services
  final AuthService _authService = AuthService();
  final PaymentService _paymentService = PaymentService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  // New API repositories (lazy initialized)
  AuthRepository? _authRepository;
  PartnerRepository? _partnerRepository;
  WalletRepository? _walletRepository;
  RouterRepository? _routerRepository;
  
  // Feature flag to toggle between mock and real API
  bool _useRemoteApi = ApiConfig.useRemoteApi;
  
  bool get useRemoteApi => _useRemoteApi;
  
  /// Toggle between mock data and real API (for testing)
  void setUseRemoteApi(bool value) {
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
    }
  }
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  List<UserModel> _users = [];
  List<RouterModel> _routers = [];
  List<PlanModel> _plans = [];
  List<TransactionModel> _transactions = [];
  double _walletBalance = 0.0;
  List<HotspotProfileModel> _hotspotProfiles = [];
  List<RouterConfigurationModel> _routerConfigurations = [];
  List<RoleModel> _roles = [];
  
  final List<NotificationModel> _notifications = [];
  final List<ProfileModel> _profiles = [];
  LanguageModel _selectedLanguage = LanguageModel.availableLanguages.first;
  SubscriptionModel? _subscription;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;
  List<RouterModel> get routers => _routers;
  List<PlanModel> get plans => _plans;
  List<TransactionModel> get transactions => _transactions;
  double get walletBalance => _walletBalance;
  List<HotspotProfileModel> get hotspotProfiles => _hotspotProfiles;
  List<RouterConfigurationModel> get routerConfigurations => _routerConfigurations;
  List<RoleModel> get roles => _roles;
  
  List<NotificationModel> get notifications => _notifications;
  List<ProfileModel> get profiles => _profiles;
  LanguageModel get selectedLanguage => _selectedLanguage;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;
  SubscriptionModel? get subscription => _subscription;
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      if (_useRemoteApi) {
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
      } else {
        // Use mock service
        final result = await _authService.login(email, password);
        _currentUser = UserModel.fromJson(result['user']);
        await loadDashboardData();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      if (_useRemoteApi) {
        // Use real API
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
      } else {
        // Use mock service
        final result = await _authService.register(name, email, password);
        _currentUser = UserModel.fromJson(result['user']);
        await loadDashboardData();
        _setLoading(false);
        return true;
      }
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
      if (_useRemoteApi) {
        // Use real API
        _initializeRepositories();
        final success = await _authRepository!.register(
          firstName: fullName,
          email: email,
          password: password,
          phone: phone,
          businessName: businessName,
          address: address,
          city: city,
          country: country,
          numberOfRouters: numberOfRouters,
        );
        if (success) {
          // Try to load profile to get user data
          // If registration requires email verification, this might fail
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
            // If profile fetch fails (e.g., email verification required),
            // create a temporary user model
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
      } else {
        // Use mock service
        final result = await _authService.register(fullName, email, password);
        _currentUser = UserModel.fromJson(result['user']);
        await loadDashboardData();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> logout() async {
    if (_useRemoteApi && _authRepository != null) {
      await _authRepository!.logout();
    } else {
      await _authService.logout();
    }
    _currentUser = null;
    _users = [];
    _routers = [];
    _plans = [];
    _transactions = [];
    _walletBalance = 0.0;
    notifyListeners();
  }
  
  Future<void> checkAuthStatus() async {
    if (_useRemoteApi) {
      // Check if we have a saved token and initialize repositories
      _initializeRepositories();
      final tokenStorage = TokenStorage();
      final accessToken = await tokenStorage.getAccessToken();
      
      if (accessToken != null) {
        // Try to fetch profile to verify token is still valid
        try {
          final profileData = await _partnerRepository!.fetchProfile();
          if (profileData != null) {
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
    } else {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        await loadDashboardData();
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
      _subscription = SubscriptionModel(
        id: '1',
        tier: 'Standard',
        renewalDate: DateTime(2023, 12, 10),
        isActive: true,
        monthlyFee: 29.99,
        features: {
          'maxRouters': 5,
          'maxUsers': 100,
          'support': '24/7',
        },
      );
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
      if (_useRemoteApi) {
        // Ensure repositories are initialized
        if (_partnerRepository == null) _initializeRepositories();
        
        // Note: Customer list endpoint needs to be verified with backend
        // For now, return empty list as the endpoint returns 404
        _users = [];
      } else {
        _users = await _authService.getUsers();
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadRouters() async {
    try {
      if (_useRemoteApi) {
        // Ensure repositories are initialized
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
      } else {
        _routers = await _connectivityService.getRouters();
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadPlans() async {
    try {
      if (_useRemoteApi) {
        // Ensure repositories are initialized
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
      } else {
        _plans = await _paymentService.getPlans();
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadTransactions() async {
    try {
      if (_useRemoteApi) {
        // Ensure repositories are initialized
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
      } else {
        _transactions = await _paymentService.getTransactions();
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadWalletBalance() async {
    try {
      if (_useRemoteApi) {
        // Ensure repositories are initialized
        if (_walletRepository == null) _initializeRepositories();
        
        final balanceData = await _walletRepository!.fetchBalance();
        if (balanceData != null) {
          // API returns 'wallet_balance', not 'balance'
          final balanceStr = balanceData['wallet_balance']?.toString() ?? '0.0';
          _walletBalance = double.tryParse(balanceStr) ?? 0.0;
        }
      } else {
        _walletBalance = await _paymentService.getWalletBalance();
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> createUser(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      await _authService.createUser(userData);
      await loadUsers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      await _authService.updateUser(id, userData);
      await loadUsers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> deleteUser(String id) async {
    _setLoading(true);
    try {
      await _authService.deleteUser(id);
      await loadUsers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> createPlan(Map<String, dynamic> planData) async {
    _setLoading(true);
    try {
      await _paymentService.createPlan(planData);
      await loadPlans();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> assignPlan(String userId, String planId) async {
    _setLoading(true);
    try {
      await _paymentService.assignPlan(userId, planId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> requestPayout(double amount, String method) async {
    _setLoading(true);
    try {
      await _paymentService.requestPayout(amount, method);
      await loadTransactions();
      await loadWalletBalance();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> createRouter(Map<String, dynamic> routerData) async {
    _setLoading(true);
    try {
      await _connectivityService.createRouter(routerData);
      await loadRouters();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> blockDevice(String deviceId) async {
    _setLoading(true);
    try {
      await _connectivityService.blockDevice(deviceId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> unblockDevice(String deviceId) async {
    _setLoading(true);
    try {
      await _connectivityService.unblockDevice(deviceId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
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
