import 'package:flutter/foundation.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/collaborator_repository.dart';
import '../../repositories/role_repository.dart';
import '../../repositories/plan_repository.dart';
import '../../models/user_model.dart';
import '../../models/worker_model.dart';
import '../../models/role_model.dart';
import '../../models/subscription_model.dart';
import '../../models/local_notification_model.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/local_notification_service.dart';
import '../../utils/currency_utils.dart';
import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  CustomerRepository? _customerRepository;
  CollaboratorRepository? _collaboratorRepository;
  RoleRepository? _roleRepository;
  SubscriptionRepository? _subscriptionRepository;
  PlanRepository? _planRepository;
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  
  List<UserModel> _users = [];
  List<WorkerModel> _workers = [];
  List<RoleModel> _roles = [];

  // UserModel? _currentUser; // Moved to AuthProvider
  
  bool _isLoading = false;
  String? _error;
  SubscriptionModel? _subscription;
  bool _isSubscriptionLoaded = false;
  bool _hasSkippedSubscriptionCheck = false;
  bool _isGuestMode = false;
  String? _partnerCountry;
  List<SubscriptionPlanModel> _availableSubscriptionPlans = [];

  UserProvider({
    CustomerRepository? customerRepository,
    CollaboratorRepository? collaboratorRepository,
    RoleRepository? roleRepository,

    AuthProvider? authProvider,
    SubscriptionRepository? subscriptionRepository,
    PlanRepository? planRepository,
  }) : _customerRepository = customerRepository,
       _collaboratorRepository = collaboratorRepository,
       _roleRepository = roleRepository,
       _authProvider = authProvider,
       _subscriptionRepository = subscriptionRepository,
       _planRepository = planRepository;

  void update({
    CustomerRepository? customerRepository,
    CollaboratorRepository? collaboratorRepository,
    RoleRepository? roleRepository,
    SubscriptionRepository? subscriptionRepository,
    PlanRepository? planRepository,
    AuthProvider? authProvider,
  }) {
    _authProvider = authProvider;
    _customerRepository = customerRepository;
    _collaboratorRepository = collaboratorRepository;
    _roleRepository = roleRepository;
    _subscriptionRepository = subscriptionRepository;
    _planRepository = planRepository;

    if (authProvider?.currentUser == null) {
      _subscription = null;
      _isSubscriptionLoaded = false;
      _hasSkippedSubscriptionCheck = false;
    } else if (authProvider?.subscriptionData != null && (_subscription == null || authProvider!.subscriptionData != _authProvider?.subscriptionData)) {
       // Use pre-loaded subscription data (especially for workers/managers)
       try {
         _subscription = SubscriptionModel.fromJson(authProvider!.subscriptionData!);
         _isSubscriptionLoaded = true;
         if (kDebugMode) debugPrint('✅ [UserProvider] Inherited partner subscription: ${_subscription!.tier}');
       } catch (e) {
         if (kDebugMode) debugPrint('❌ [UserProvider] Error mapping pre-loaded subscription: $e');
       }
    }
    notifyListeners();
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
  bool get isSubscriptionLoaded => _isSubscriptionLoaded;
  bool get hasSkippedSubscriptionCheck => _hasSkippedSubscriptionCheck;
  bool get isGuestMode => _isGuestMode;
  String? get partnerCountry => _partnerCountry ?? _authProvider?.partnerCountry;
  List<SubscriptionPlanModel> get availableSubscriptionPlans => _availableSubscriptionPlans;
  
  // Local notifications
  List<LocalNotification> get localNotifications => _localNotificationService.notifications;
  int get localUnreadCount => _localNotificationService.unreadCount;
  Stream<LocalNotification> get localNotificationStream => _localNotificationService.notificationStream;

  String get currencyCode {
    return CurrencyUtils.getCurrencySymbol(_partnerCountry ?? _authProvider?.partnerCountry);
  }

  /// Get payment details for Paystack inline popup
  Map<String, dynamic> getPaymentDetails({
    required String planId,
    required String planName,
    required double amount,
    String? planCurrency,
  }) {
    final email = _authProvider?.currentUser?.email;
    if (email == null) {
      throw Exception('User email not found');
    }
    
    // Normalize currency: priority to planCurrency if valid, otherwise user default
    final rawCurrencyCode = (planCurrency != null && planCurrency.isNotEmpty && planCurrency != 'Unknown') 
        ? planCurrency 
        : _getCurrencyCodeForPayment();
        
    final normalizedCurrency = _normalizeCurrencyCode(rawCurrencyCode);
    
    return {
      'email': email,
      'amount': amount,
      'planId': planId,
      'planName': planName,
      'currency': normalizedCurrency,
      'userData': {
        'firstName': _authProvider?.currentUser?.firstName,
        'lastName': _authProvider?.currentUser?.lastName,
        'address': _authProvider?.currentUser?.address,
        'city': _authProvider?.currentUser?.city,
        'country': _getIsoCountryCode(_partnerCountry) ?? '', 
        'phone': _authProvider?.currentUser?.phone,
      },
    };
  }

  String _normalizeCurrencyCode(String code) {
    // Map symbols OR existing codes to standard Paystack/CinetPay ISO codes
    switch (code) {
      case 'GH₵': 
      case 'GHS': return 'GHS';
      case 'KSh': 
      case 'KES': return 'KES';
      case 'FG': 
      case 'GNF': return 'GNF';
      case 'CFA': 
      case 'XOF': return 'XOF';
      case 'XAF': return 'XAF';
      case '₦': 
      case 'NGN': return 'NGN';
      case 'USh': 
      case 'UGX': return 'UGX';
      case 'TSh': 
      case 'TZS': return 'TZS';
      case 'RF': 
      case 'RWF': return 'RWF';
      case 'R': 
      case 'ZAR': return 'ZAR';
      case '\$': 
      case 'USD': return 'USD';
      default: return code.length == 3 ? code : 'NGN';
    }
  }

  String _getCurrencyCodeForPayment() {
    return _normalizeCurrencyCode(currencyCode);
  }


  Future<void> loadAssignedPlans() async {
    if (_customerRepository == null) return;
    try {
      if (kDebugMode) debugPrint('📡 [UserProvider] Loading assigned plans...');
      final plans = await _customerRepository!.fetchAssignedPlans();
      _assignedPlans = plans;
      _error = null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error loading assigned plans: $e');
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadPurchasedPlans() async {
    if (_customerRepository == null) return;
    try {
      if (kDebugMode) debugPrint('📡 [UserProvider] Loading purchased plans...');
      final plans = await _customerRepository!.fetchPurchasedPlans();
      _purchasedPlans = plans;
      _error = null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error loading purchased plans: $e');
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
      if (kDebugMode) debugPrint('❌ [UserProvider] Error creating user: $e');
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
      if (kDebugMode) debugPrint('❌ [UserProvider] Error updating user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String username) async {
    if (_customerRepository == null) return;
    _setLoading(true);
    try {
      await _customerRepository!.deleteCustomer(username);
      await loadUsers();
      _error = null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error deleting user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUsers() async {
    if (_customerRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) debugPrint('📡 [UserProvider] Loading users from API...');
      
      List<String> activeSessions = [];
      try {
        activeSessions = await _customerRepository!.getActiveSessions();
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ [UserProvider] Failed to load active sessions: $e');
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
      if (kDebugMode) debugPrint('❌ [UserProvider] Error toggling block status: $e');
      rethrow;
    }
  }

  // ==================== Workers ====================

  Future<void> loadWorkers() async {
    if (_collaboratorRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) debugPrint('📡 [UserProvider] Loading workers...');
      final workersData = await _collaboratorRepository!.fetchCollaborators();
      _workers = workersData.map((data) => WorkerModel.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error loading workers: $e');
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
      if (kDebugMode) debugPrint('❌ [UserProvider] Error deleting worker: $e');
      rethrow;
    }
  }

  Future<void> assignRoleToWorker(String username, String roleId) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.assignRole(username, {'role_id': roleId});
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error assigning role: $e');
      rethrow;
    }
  }

  Future<void> updateWorkerRole(String username, String roleId) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.updateRole(username, {'role': roleId});
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error updating worker role: $e');
      rethrow;
    }
  }

  Future<void> createWorker(Map<String, dynamic> workerData) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.createCollaborator(workerData);
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error creating worker: $e');
      rethrow;
    }
  }
  
  Future<void> updateWorker(String username, Map<String, dynamic> workerData) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.updateCollaborator(username, workerData);
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error updating worker: $e');
      rethrow;
    }
  }

  Future<void> assignRouterToWorker(String username, String routerId) async {
    if (_collaboratorRepository == null) return;
    try {
      await _collaboratorRepository!.assignRouter(username, {'router_id': routerId});
      await loadWorkers();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error assigning router to worker: $e');
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
      if (kDebugMode) debugPrint('📡 [UserProvider] Loading roles...');
      final rolesData = await repo.fetchRoles();
      _roles = rolesData.map((data) => RoleModel.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error loading roles: $e');
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
      if (kDebugMode) debugPrint('❌ [UserProvider] Error creating role: $e');
      rethrow;
    }
  }

  Future<void> updateRole(String slug, Map<String, dynamic> roleData) async {
    if (_roleRepository == null) return;
    try {
      await _roleRepository!.updateRole(slug, roleData);
      await loadRoles();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error updating role: $e');
      rethrow;
    }
  }

  Future<void> deleteRole(String slug) async {
    if (_roleRepository == null) return;
    try {
      await _roleRepository!.deleteRole(slug);
      await loadRoles();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error deleting role: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchPermissions() async {
    if (_roleRepository == null) return [];
    try {
      return await _roleRepository!.fetchPermissions();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error fetching permissions: $e');
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
    
    // Workaround: Workers/Managers usually inherit subscription from Partner
    // If they have it already and are not partners, don't try to fetch (avoids 403 Forbidden)
    final userRole = _authProvider?.currentUser?.role.toLowerCase();
    if (userRole != 'partner' && userRole != 'owner' && _subscription != null) {
      if (kDebugMode) debugPrint('ℹ️ [UserProvider] Skipping subscription fetch for $userRole (using inherited plan)');
      return;
    }

    try {
      if (kDebugMode) debugPrint('📡 [UserProvider] Loading subscription status...');
      final subscriptionData = await _subscriptionRepository!.checkSubscriptionStatus();
      
      if (subscriptionData != null) {
        final data = subscriptionData['data'] is Map ? subscriptionData['data'] : subscriptionData;
        _subscription = SubscriptionModel.fromJson(data);
        if (kDebugMode) debugPrint('✅ [UserProvider] Subscription loaded: ${_subscription!.tier}');
      } else {
        _subscription = null;
      }
      _error = null;
      _isSubscriptionLoaded = true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Error loading subscription: $e');
      _error = e.toString();
      _isSubscriptionLoaded = true; // Still marked as loaded even on error to stop infinite loading
    } finally {
      notifyListeners();
    }
  }

  /// Load available subscription plans
  Future<void> loadAvailableSubscriptionPlans() async {
    if (_subscriptionRepository == null) return;
    try {
      if (kDebugMode) debugPrint('📋 [UserProvider] Loading available subscription plans');
      final plansData = await _subscriptionRepository!.fetchSubscriptionPlans(
        country: _partnerCountry ?? _authProvider?.partnerCountry,
      );
      List<SubscriptionPlanModel> allPlans = [];
      
      for (var planData in plansData) {
        if (planData is! Map<String, dynamic>) continue;
        
        final priceInfoList = planData['price_info'];
        if (priceInfoList is List && priceInfoList.isNotEmpty) {
          // Create a plan model for each price option (duration)
          for (var priceInfo in priceInfoList) {
             if (priceInfo is Map<String, dynamic>) {
               // Merge base plan data with specific price info
               final mergedData = Map<String, dynamic>.from(planData);
               mergedData['price_info'] = priceInfo; // Override with single price info map for parsing
               // Also override top-level duration/price for easier consumption if needed
               mergedData['duration'] = priceInfo['duration']?.toString() ?? 'monthly';
               mergedData['price'] = priceInfo['price'];
               
               allPlans.add(SubscriptionPlanModel.fromJson(mergedData));
             }
          }
        } else {
           // Fallback for plans without price_info list (e.g. legacy or simple structure)
           // If 'price' exists at top level or in price_info map
           if (planData['price'] != null || (priceInfoList is Map && priceInfoList['price'] != null)) {
              allPlans.add(SubscriptionPlanModel.fromJson(planData));
           }
        }
      }

      _availableSubscriptionPlans = allPlans
          .where((plan) => plan.price > 0 || plan.name == "Free Access") // Keep valid paid plans OR free plans (price might comprise 0 or 1)
          .toList();
      
      if (kDebugMode) debugPrint('✅ [UserProvider] Loaded ${_availableSubscriptionPlans.length} subscription plans');
      _error = null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Load available subscription plans error: $e');
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
        debugPrint('💳 [UserProvider] Purchasing subscription plan: $planId');
        debugPrint('   Payment reference: $paymentReference');
      }
      final result = await _subscriptionRepository!.purchaseSubscription(planId, paymentReference);
      
      if (result != null) {
        if (kDebugMode) debugPrint('✅ [UserProvider] Subscription purchase successful');
        // Reload subscription to get updated data
        await loadSubscription();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Purchase subscription error: $e');
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

  void skipSubscriptionCheck() {
    _hasSkippedSubscriptionCheck = true;
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
      if (kDebugMode) debugPrint('📡 [UserProvider] Assigning plan $planId to user $userId${routerId != null ? ' on router $routerId' : ''}');
      
      final data = {
        'customer_id': int.tryParse(userId) ?? userId,
        'plan_id': int.tryParse(planId) ?? planId,
        if (routerId != null) 'router_id': int.tryParse(routerId) ?? routerId,
        // Tag transaction with worker/manager first name if not partner/owner
        if (_authProvider?.currentUser != null && 
            _authProvider!.currentUser!.role.toLowerCase() != 'partner' && 
            _authProvider!.currentUser!.role.toLowerCase() != 'owner')
          'tag': _authProvider!.currentUser!.name.split(' ').first,
      };

      await _planRepository!.assignPlan(data);
      
      if (kDebugMode) debugPrint('✅ [UserProvider] Plan assigned successfully');
      
      // Refresh data
      await loadSubscription();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [UserProvider] Assign plan error: $e');
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
      case 'guinea': return 'GN';
      case 'burkina faso': return 'BF';
      case 'niger': return 'NE';
      case 'cameroon': return 'CM';
      case 'gabon': return 'GA';
      case 'congo': return 'CG';
      case 'chad': return 'TD';
      case 'nigeria': return 'NG';
      case 'ghana': return 'GH';
      case 'kenya': return 'KE';
      default: return null; 
    }
  }
}
