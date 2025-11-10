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
      final result = await _authService.register(name, email, password);
      _currentUser = UserModel.fromJson(result['user']);
      await loadDashboardData();
      _setLoading(false);
      return true;
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
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      await loadDashboardData();
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
    
    _hotspotProfiles = [
      HotspotProfileModel(
        id: '1',
        name: 'Basic',
        downloadSpeedMbps: 10,
        uploadSpeedMbps: 5,
        idleTimeout: '30m',
      ),
      HotspotProfileModel(
        id: '2',
        name: 'Standard',
        downloadSpeedMbps: 20,
        uploadSpeedMbps: 10,
        idleTimeout: '1h',
      ),
      HotspotProfileModel(
        id: '3',
        name: 'Premium',
        downloadSpeedMbps: 50,
        uploadSpeedMbps: 25,
        idleTimeout: '2h',
      ),
      HotspotProfileModel(
        id: '4',
        name: 'Ultra',
        downloadSpeedMbps: 100,
        uploadSpeedMbps: 50,
        idleTimeout: '5h',
      ),
    ];

    _routerConfigurations = [
      RouterConfigurationModel(
        id: '1',
        name: 'Router Alpha',
        ipAddress: '192.168.1.1',
        apiPort: 8080,
        username: 'admin',
      ),
      RouterConfigurationModel(
        id: '2',
        name: 'Router Beta',
        ipAddress: '192.168.1.2',
        apiPort: 8080,
        username: 'admin',
      ),
      RouterConfigurationModel(
        id: '3',
        name: 'Router Gamma',
        ipAddress: '192.168.1.3',
        apiPort: 8080,
        username: 'admin',
      ),
    ];

    _roles = [
      RoleModel(
        id: '1',
        name: 'Administrator',
        permissions: {
          'dashboard_access': true,
          'user_create': true,
          'user_read': true,
          'user_update': true,
          'user_delete': true,
          'plan_create': true,
          'plan_read': true,
          'plan_update': true,
          'plan_delete': true,
          'transaction_viewing': true,
          'router_management': true,
          'settings_access': true,
        },
      ),
      RoleModel(
        id: '2',
        name: 'Manager',
        permissions: {
          'dashboard_access': true,
          'user_read': true,
          'plan_read': true,
          'transaction_viewing': true,
          'router_management': false,
          'settings_access': false,
        },
      ),
      RoleModel(
        id: '3',
        name: 'Worker',
        permissions: {
          'dashboard_access': true,
          'user_read': true,
          'plan_read': false,
          'transaction_viewing': false,
          'router_management': true,
          'settings_access': false,
        },
      ),
    ];
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
      _users = await _authService.getUsers();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadRouters() async {
    try {
      if (_useRemoteApi && _routerRepository != null) {
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
      _plans = await _paymentService.getPlans();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadTransactions() async {
    try {
      _transactions = await _paymentService.getTransactions();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadWalletBalance() async {
    try {
      if (_useRemoteApi && _walletRepository != null) {
        final balanceData = await _walletRepository!.fetchBalance();
        if (balanceData != null) {
          _walletBalance = (balanceData['balance'] as num?)?.toDouble() ?? 0.0;
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
