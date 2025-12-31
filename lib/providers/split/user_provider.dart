import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/collaborator_repository.dart';
import '../../repositories/role_repository.dart';
import '../../repositories/partner_repository.dart';
import '../../repositories/plan_repository.dart';
import '../../models/user_model.dart';
import '../../models/worker_model.dart';
import '../../models/role_model.dart';
import '../../models/plan_model.dart';
import '../../models/subscription_model.dart';
import '../../models/local_notification_model.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/local_notification_service.dart';

import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  CustomerRepository? _customerRepository;
  CollaboratorRepository? _collaboratorRepository;
  RoleRepository? _roleRepository;
  SubscriptionRepository? _subscriptionRepository;
  PartnerRepository? _partnerRepository;
  PlanRepository? _planRepository;
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  
  List<UserModel> _users = [];
  List<WorkerModel> _workers = [];
  List<RoleModel> _roles = [];

  // UserModel? _currentUser; // Moved to AuthProvider
  
  bool _isLoading = false;
  String? _error;
  SubscriptionModel? _subscription;
  bool _isGuestMode = false;
  String? _partnerCountry;
  List<SubscriptionPlanModel> _availableSubscriptionPlans = [];

  UserProvider({
    CustomerRepository? customerRepository,
    CollaboratorRepository? collaboratorRepository,
    RoleRepository? roleRepository,

    AuthProvider? authProvider,
    SubscriptionRepository? subscriptionRepository,
    PartnerRepository? partnerRepository,
    PlanRepository? planRepository,
  }) : _customerRepository = customerRepository,
       _collaboratorRepository = collaboratorRepository,
       _roleRepository = roleRepository,
       _authProvider = authProvider,
       _subscriptionRepository = subscriptionRepository;

  void update({
    CustomerRepository? customerRepository,
    CollaboratorRepository? collaboratorRepository,
    RoleRepository? roleRepository,
    SubscriptionRepository? subscriptionRepository,
    PartnerRepository? partnerRepository,
    PlanRepository? planRepository,
    AuthProvider? authProvider,
  }) {
    _authProvider = authProvider;
    _customerRepository = customerRepository;
    _collaboratorRepository = collaboratorRepository;
    _roleRepository = roleRepository;
    _subscriptionRepository = subscriptionRepository;
    _partnerRepository = partnerRepository;
    _planRepository = planRepository;

    // _currentUser = currentUser; // Handled by AuthProvider
  }

  List<dynamic> _assignedPlans = [];
  List<dynamic> _purchasedPlans = [];
  
  List<UserModel> get users => _users;
  List<WorkerModel> get workers => _workers;
  List<RoleModel> get roles => _roles;

  UserModel? get currentUser => _authProvider?.currentUser;
  List<dynamic> get assignedPlans => _assignedPlans;
  List<dynamic> get purchasedPlans => _purchasedPlans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SubscriptionModel? get subscription => _subscription;
  bool get isGuestMode => _isGuestMode;
  String? get partnerCountry => _partnerCountry ?? _authProvider?.partnerCountry;
  List<SubscriptionPlanModel> get availableSubscriptionPlans => _availableSubscriptionPlans;
  
  // Local notifications
  List<LocalNotification> get localNotifications => _localNotificationService.notifications;
  int get localUnreadCount => _localNotificationService.unreadCount;
  Stream<LocalNotification> get localNotificationStream => _localNotificationService.notificationStream;

  String get currencyCode {
    final country = _partnerCountry ?? _authProvider?.partnerCountry;
    if (country == null || country.isEmpty) return '₦';
    
    // Mapping from country name/code to currency symbol
    switch (country.toLowerCase()) {
      case 'ghana': return 'GH₵';
      case 'kenya': return 'KSh';
      case 'nigeria': return '₦';
      case 'côte d\'ivoire':
      case 'ivory coast':
      case 'senegal':
      case 'mali':
      case 'benin':
      case 'togo':
      case 'burkina faso':
      case 'niger':
      case 'guinea-bissau':
        return 'XOF';
      case 'cameroon':
      case 'gabon':
      case 'congo':
      case 'chad':
      case 'central african republic':
      case 'equatorial guinea':
        return 'XAF';
      default: return '₦';
    }
  }

  /// Get payment details for Paystack inline popup
  Map<String, dynamic> getPaymentDetails({
    required String planId,
    required String planName,
    required double amount,
  }) {
    final email = _authProvider?.currentUser?.email;
    if (email == null) {
      throw Exception('User email not found');
    }
    
    return {
      'email': email,
      'amount': amount,
      'planId': planId,
      'planName': planName,
      'currency': _getCurrencyCodeForPayment(),
      'userData': {
        'firstName': _authProvider?.currentUser?.firstName,
        'lastName': _authProvider?.currentUser?.lastName,
        'address': _authProvider?.currentUser?.address,
        'city': _authProvider?.currentUser?.city,
        'country': _getIsoCountryCode(_partnerCountry) ?? 'CI', 
        'phone': _authProvider?.currentUser?.phone,
      },
    };
  }

  String _getCurrencyCodeForPayment() {
  // Current mapping for Paystack and CinetPay supported currencies
  switch (currencyCode) {
    case 'GH₵': return 'GHS';
    case 'KSh': return 'KES';
    case 'FCFA': return 'XOF'; // Defaulting FCFA to XOF for CinetPay
    case 'XOF': return 'XOF';
    case 'XAF': return 'XAF';
    default: return 'NGN';
  }
}


  Future<void> loadAssignedPlans() async {
    if (_customerRepository == null) return;
    try {
      if (kDebugMode) print('📡 [UserProvider] Loading assigned plans...');
      final plans = await _customerRepository!.fetchAssignedPlans();
      _assignedPlans = plans;
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error loading assigned plans: $e');
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadPurchasedPlans() async {
    if (_customerRepository == null) return;
    try {
      if (kDebugMode) print('📡 [UserProvider] Loading purchased plans...');
      final plans = await _customerRepository!.fetchPurchasedPlans();
      _purchasedPlans = plans;
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error loading purchased plans: $e');
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==================== Customers ====================

  Future<void> createUser(Map<String, dynamic> userData) async {
    if (_customerRepository == null) return;
    _setLoading(true);
    try {
      await _customerRepository!.createCustomer(userData);
      await loadUsers();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error creating user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    if (_customerRepository == null) return;
    _setLoading(true);
    try {
      await _customerRepository!.updateCustomer(userId, userData);
      await loadUsers();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error updating user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String userId) async {
    if (_customerRepository == null) return;
    _setLoading(true);
    try {
      await _customerRepository!.deleteCustomer(userId);
      await loadUsers();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error deleting user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUsers() async {
    if (_customerRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [UserProvider] Loading users from API...');
      
      List<String> activeSessions = [];
      try {
        activeSessions = await _customerRepository!.getActiveSessions();
      } catch (e) {
        if (kDebugMode) print('⚠️ [UserProvider] Failed to load active sessions: $e');
        // Continue with empty active sessions
      }

      final response = await _customerRepository!.fetchCustomers(page: 1, pageSize: 20);
      
      if (response != null) {
        List<dynamic>? usersList;
        if (response['data'] is Map && response['data']['results'] is List) {
          usersList = response['data']['results'] as List;
        } else if (response['results'] is List) {
          usersList = response['results'] as List;
        } else if (response['data'] is List) {
          usersList = response['data'] as List;
        }
        
        if (usersList != null) {
          _users = usersList.map((u) {
            final username = u['username'] as String?;
            final isConnected = username != null && activeSessions.contains(username);
            return UserModel.fromJson(u, isConnected: isConnected);
          }).toList();
          _error = null;
        } else {
          _users = [];
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error loading users: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleUserBlock(String username, bool currentlyBlocked) async {
    if (_customerRepository == null) return;
    try {
      if (currentlyBlocked) {
        await _customerRepository!.unblockCustomer(username);
      } else {
        await _customerRepository!.blockCustomer(username);
      }
      
      final index = _users.indexWhere((u) => u.username == username);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isBlocked: !currentlyBlocked);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error toggling block status: $e');
      rethrow;
    }
  }

  // ==================== Workers ====================

  Future<void> loadWorkers() async {
    if (_collaboratorRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [UserProvider] Loading workers...');
      final workersData = await _collaboratorRepository!.fetchCollaborators();
      _workers = workersData.map((data) => WorkerModel.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error loading workers: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteWorker(String username) async {
    if (_collaboratorRepository == null) return;
    try {
      final success = await _collaboratorRepository!.deleteCollaborator(username);
      if (success) {
        await loadWorkers();
      }
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error deleting worker: $e');
      rethrow;
    }
  }

  Future<void> assignRoleToWorker(String username, String roleId) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.assignRole(username, {'role_id': roleId});
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error assigning role: $e');
      rethrow;
    }
  }

  Future<void> updateWorkerRole(String username, String roleId) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.updateRole(username, {'role': roleId});
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error updating worker role: $e');
      rethrow;
    }
  }

  Future<void> createWorker(Map<String, dynamic> workerData) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.createCollaborator(workerData);
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error creating worker: $e');
      rethrow;
    }
  }
  
  Future<void> updateWorker(String username, Map<String, dynamic> workerData) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.updateCollaborator(username, workerData);
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error updating worker: $e');
      rethrow;
    }
  }

  Future<void> assignRouterToWorker(String username, String routerId) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.assignRouter(username, {'router_id': routerId});
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error assigning router to worker: $e');
      rethrow;
    }
  }

  // ==================== Roles ====================

  Future<void> loadRoles() async {
    // Both repositories have fetchRoles, using roleRepository as primary
    final repo = _roleRepository ?? (_collaboratorRepository as dynamic);
    if (repo == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [UserProvider] Loading roles...');
      final rolesData = await repo.fetchRoles();
      _roles = rolesData.map((data) => RoleModel.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error loading roles: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createRole(Map<String, dynamic> roleData) async {
    if (_roleRepository == null) return;
    try {
      await _roleRepository!.createRole(roleData);
      await loadRoles();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error creating role: $e');
      rethrow;
    }
  }

  Future<void> updateRole(String slug, Map<String, dynamic> roleData) async {
    if (_roleRepository == null) return;
    try {
      await _roleRepository!.updateRole(slug, roleData);
      await loadRoles();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error updating role: $e');
      rethrow;
    }
  }

  Future<void> deleteRole(String slug) async {
    if (_roleRepository == null) return;
    try {
      await _roleRepository!.deleteRole(slug);
      await loadRoles();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error deleting role: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchPermissions() async {
    if (_roleRepository == null) return [];
    try {
      return await _roleRepository!.fetchPermissions();
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error fetching permissions: $e');
      rethrow;
    }
  }

  // Helper methods
  Future<Map<String, dynamic>?> getCustomerDataUsage(String username) async => 
      await _customerRepository?.getCustomerDataUsage(username);

  Future<List<dynamic>> getCustomerTransactions(String username) async => 
      await _customerRepository?.getCustomerTransactions(username) ?? [];

  // ==================== Subscription ====================

  Future<void> loadSubscription() async {
    if (_subscriptionRepository == null) return;
    try {
      if (kDebugMode) print('📡 [UserProvider] Loading subscription status...');
      final subscriptionData = await _subscriptionRepository!.checkSubscriptionStatus();
      
      if (subscriptionData != null) {
        final data = subscriptionData['data'] is Map ? subscriptionData['data'] : subscriptionData;
        _subscription = SubscriptionModel.fromJson(data);
        if (kDebugMode) print('✅ [UserProvider] Subscription loaded: ${_subscription!.tier}');
      } else {
        _subscription = null;
      }
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Error loading subscription: $e');
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Load available subscription plans
  Future<void> loadAvailableSubscriptionPlans() async {
    if (_subscriptionRepository == null) return;
    try {
      if (kDebugMode) print('📋 [UserProvider] Loading available subscription plans');
      final plansData = await _subscriptionRepository!.fetchSubscriptionPlans();
      
      _availableSubscriptionPlans = plansData
          .map<SubscriptionPlanModel>((data) => SubscriptionPlanModel.fromJson(data))
          .toList();
      
      if (kDebugMode) print('✅ [UserProvider] Loaded ${_availableSubscriptionPlans.length} subscription plans');
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Load available subscription plans error: $e');
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Purchase a subscription plan
  Future<bool> purchaseSubscriptionPlan(String planId, String paymentReference) async {
    if (_subscriptionRepository == null) return false;
    _setLoading(true);
    try {
      if (kDebugMode) {
        print('💳 [UserProvider] Purchasing subscription plan: $planId');
        print('   Payment reference: $paymentReference');
      }
      final result = await _subscriptionRepository!.purchaseSubscription(planId, paymentReference);
      
      if (result != null) {
        if (kDebugMode) print('✅ [UserProvider] Subscription purchase successful');
        // Reload subscription to get updated data
        await loadSubscription();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Purchase subscription error: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Guest Mode ====================

  void setGuestMode(bool value) {
    _isGuestMode = value;
    notifyListeners();
  }

  // ==================== Local Notifications ====================
  
  void markNotificationAsRead(String id) {
    _localNotificationService.markAsRead(id);
    notifyListeners();
  }

  void markAllLocalNotificationsAsRead() {
    _localNotificationService.markAllAsRead();
    notifyListeners();
  }

  void dismissNotification(String id) {
    _localNotificationService.deleteNotification(id);
    notifyListeners();
  }

  // Wrapper for consistency
  void markAllNotificationsAsRead() => markAllLocalNotificationsAsRead();
  
  // Note: loadNotifications is usually auto-handled by the service on init, 
  // but we can expose a refresh if needed, or just rely on the getter.
  void loadNotifications() {
     // Service usually loads on init. 
     // We can just notify listeners to ensure UI updates if needed.
     notifyListeners();
  }

  Map<String, bool> getNotificationSettings() {
    return _localNotificationService.getSettings();
  }

  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    await _localNotificationService.updateSettings(settings);
    notifyListeners();
  }



  /// Assign a plan to a user
  Future<bool> assignPlan(String userId, String planId, {String? routerId}) async {
    if (_planRepository == null) return false;
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [UserProvider] Assigning plan $planId to user $userId${routerId != null ? ' on router $routerId' : ''}');
      
      final data = {
        'user_id': userId,
        'plan_id': planId,
        if (routerId != null) 'router_id': routerId,
      };

      await _planRepository!.assignPlan(data);
      
      if (kDebugMode) print('✅ [UserProvider] Plan assigned successfully');
      
      // Refresh data
      await loadSubscription();
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [UserProvider] Assign plan error: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String? _getIsoCountryCode(String? countryName) {
    if (countryName == null) return null;
    switch (countryName.toLowerCase()) {
      case 'côte d\'ivoire':
      case 'cote d\'ivoire':
      case 'ivory coast': return 'CI';
      case 'senegal': return 'SN';
      case 'mali': return 'ML';
      case 'benin': return 'BJ';
      case 'togo': return 'TG';
      case 'burkina faso': return 'BF';
      case 'niger': return 'NE';
      case 'cameroon': return 'CM';
      case 'gabon': return 'GA';
      case 'congo': return 'CG';
      case 'chad': return 'TD';
      case 'nigeria': return 'NG';
      case 'ghana': return 'GH';
      case 'kenya': return 'KE';
      default: return 'CI'; // Default fallback
    }
  }
}
