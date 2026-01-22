import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../repositories/router_repository.dart';
import '../../repositories/hotspot_repository.dart';
import '../../repositories/session_repository.dart';
import '../../models/router_model.dart';
import '../../models/hotspot_profile_model.dart';
import '../../models/router_configuration_model.dart';
import '../../models/user_model.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/plan_config_repository.dart';
import '../../repositories/plan_repository.dart';
import '../../models/plan_model.dart';
import '../../providers/split/auth_provider.dart';

class NetworkProvider with ChangeNotifier {
  RouterRepository? _routerRepository;
  HotspotRepository? _hotspotRepository;
  SessionRepository? _sessionRepository;
  CustomerRepository? _customerRepository;
  PlanConfigRepository? _planConfigRepository;
  PlanRepository? _planRepository;
  AuthProvider? _authProvider;
  
  List<RouterModel> _routers = [];
  List<RouterConfigurationModel> _routerConfigurations = [];
  List<PlanModel> _plans = [];
  List<dynamic> _activeSessions = [];
  Map<String, double> _activeDataUsage = {'total_bytes': 0, 'limit_bytes': 0};
  double _totalAccumulatedBytes = 0;
  double _lastRefreshTotalBytes = 0;
  bool _isFirstUsageLoad = true;
  
  List<dynamic> _hotspotUsers = [];
  List<HotspotProfileModel> _hotspotProfiles = [];
  Map<String, List<String>> _routerAssignments = {};
  
  List<dynamic> _rateLimits = [];
  List<dynamic> _dataLimits = [];
  List<dynamic> _validityPeriods = [];
  List<dynamic> _idleTimeouts = [];
  List<dynamic> _sharedUsers = [];
  
  bool _isLoading = false;
  String? _error;

  NetworkProvider({
    RouterRepository? routerRepository,
    HotspotRepository? hotspotRepository,
    SessionRepository? sessionRepository,
    CustomerRepository? customerRepository,
    PlanConfigRepository? planConfigRepository,
    PlanRepository? planRepository,
    AuthProvider? authProvider,
  }) : _routerRepository = routerRepository,
       _hotspotRepository = hotspotRepository,
       _sessionRepository = sessionRepository,
       _customerRepository = customerRepository,
       _planConfigRepository = planConfigRepository,
       _planRepository = planRepository,
       _authProvider = authProvider {
    loadRouterAssignments();
    _loadAccumulatedUsage();
  }

  void update({
    RouterRepository? routerRepository,
    HotspotRepository? hotspotRepository,
    SessionRepository? sessionRepository,
    CustomerRepository? customerRepository,
    PlanConfigRepository? planConfigRepository,
    PlanRepository? planRepository,
    AuthProvider? authProvider,
  }) {
    _routerRepository = routerRepository;
    _hotspotRepository = hotspotRepository;
    _sessionRepository = sessionRepository;
    _customerRepository = customerRepository;
    _planConfigRepository = planConfigRepository;
    _planRepository = planRepository;
    _authProvider = authProvider;
  }

  List<RouterModel> get routers => _routers;
  List<RouterConfigurationModel> get routerConfigurations => _routerConfigurations;
  List<dynamic> get activeSessions => _activeSessions;
  Map<String, double> get activeDataUsage => _activeDataUsage;
  List<dynamic> get hotspotUsers => _hotspotUsers;
  List<HotspotProfileModel> get hotspotProfiles => _hotspotProfiles;
  List<dynamic> get rateLimits => _rateLimits;
  List<dynamic> get dataLimits => _dataLimits;
  List<dynamic> get validityPeriods => _validityPeriods;
  List<dynamic> get idleTimeouts => _idleTimeouts;
  List<dynamic> get sharedUsers => _sharedUsers;
  List<PlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<RouterModel> get visibleRouters {
    final user = _authProvider?.currentUser;
    if (user == null) return [];
    
    final role = user.role.toLowerCase();
    
    // Partners/Owners see ALL routers
    if (role == 'partner' || role == 'owner' || role == 'admin' || role == 'administrator') {
      return _routers;
    }
    
    // Workers/Managers see only assigned routers
    // Reverting to showing all routers for now as per client request (same as AppState logic)
    return _routers;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==================== Routers ====================

  Future<void> loadRouters() async {
    if (_routerRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [NetworkProvider] Loading routers...');
      final routersData = await _routerRepository!.fetchRouters();
      
      _routers = routersData.map((data) {
        try {
          return RouterModel.fromJson(data);
        } catch (e) {
          if (kDebugMode) print('❌ [NetworkProvider] Error parsing router: $data\nError: $e');
          rethrow;
        }
      }).toList();
      _routerConfigurations = routersData.map((data) => RouterConfigurationModel.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading routers: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addRouter(Map<String, dynamic> routerData) async {
    if (_routerRepository == null) return;
    _setLoading(true);
    try {
      await _routerRepository!.addRouter(routerData);
      await loadRouters();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error adding router: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRouter(String routerSlug, Map<String, dynamic> routerData) async {
    if (_routerRepository == null) return;
    _setLoading(true);
    try {
      await _routerRepository!.updateRouter(routerSlug, routerData);
      await loadRouters();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating router: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteRouter(String routerId) async {
    if (_routerRepository == null) return;
    _setLoading(true);
    try {
      await _routerRepository!.deleteRouter(routerId);
      await loadRouters();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting router: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> fetchRouterResources(String slug) async {
    if (_routerRepository == null) return {};
    try {
      return await _routerRepository!.fetchRouterResources(slug) ?? {};
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error fetching router resources: $e');
      rethrow;
    }
  }

  // Note: Router configurations are currently simplified to map to RouterModel for the list.
  // Full configuration management would require a separate API endpoint or storage if not provided by fetchRouters.
  // For now, we assume routers list contains necessary info or we fetch details on demand.
  // If RouterSettingsScreen relies on a separate list, we might need to verify the API response structure.


  Future<bool> rebootRouter(String slug) async {
    if (_routerRepository == null) return false;
    try {
      final success = await _routerRepository!.rebootRouter(slug);
      if (success) await loadRouters();
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error rebooting router: $e');
      return false;
    }
  }

  Future<bool> restartHotspot(String slug) async {
    if (_routerRepository == null) return false;
    try {
      final success = await _routerRepository!.restartHotspot(slug);
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error restarting hotspot: $e');
      return false;
    }
  }
  Future<void> blockDevice(String deviceId) async {
    if (_customerRepository == null) return;
    _setLoading(true);
    try {
      await _customerRepository!.blockCustomer(deviceId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> unblockDevice(String deviceId) async {
    if (_customerRepository == null) return;
    _setLoading(true);
    try {
      await _customerRepository!.unblockCustomer(deviceId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }



  // ==================== Customer Data ====================

  Future<Map<String, dynamic>?> getCustomerDataUsage(String username) async {
    if (_customerRepository == null) return null;
    return await _customerRepository!.getCustomerDataUsage(username);
  }

  Future<List<dynamic>> getCustomerAssignedTransactions(String username) async {
    if (_customerRepository == null) return [];
    return await _customerRepository!.getCustomerAssignedTransactions(username);
  }

  Future<List<dynamic>> getCustomerWalletTransactions(String username) async {
    if (_customerRepository == null) return [];
    return await _customerRepository!.getCustomerWalletTransactions(username);
  }

  Future<List<dynamic>> getCustomerAssignedPlans(String username) async {
    if (_customerRepository == null) return [];
    return await _customerRepository!.getCustomerAssignedPlans(username);
  }

  Future<List<dynamic>> getCustomerPurchasedPlans(String username) async {
    if (_customerRepository == null) return [];
    return await _customerRepository!.getCustomerPurchasedPlans(username);
  }

  // ==================== Sessions ====================

  Future<List<PlanModel>> loadAssignedPlans() async {
    if (_planRepository == null) return [];
    
    try {
      final response = await _planRepository!.fetchAssignedPlans();
      // response is already a List<dynamic> of plan data
      return response.map((e) => PlanModel.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) print('Error loading assigned plans: $e');
      rethrow;
    }
  }

  Future<void> loadActiveSessions() async {
    if (_sessionRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [NetworkProvider] Loading active sessions...');
      final sessions = await _sessionRepository!.fetchActiveSessions();
      print('🔍 [NetworkProvider] Raw Active Sessions: $sessions');
      
      _activeSessions = sessions;
      
      double totalBytes = 0;
      for (var session in sessions) {
        totalBytes += (session['bytes_in'] ?? 0) + (session['bytes_out'] ?? 0);
      }
      _activeDataUsage['total_bytes'] = totalBytes;
      
      // Calculate delta since last refresh to accumulate usage persistantly
      if (!_isFirstUsageLoad) {
        if (totalBytes > _lastRefreshTotalBytes) {
          double delta = totalBytes - _lastRefreshTotalBytes;
          _totalAccumulatedBytes += delta;
          _saveAccumulatedUsage();
        }
      } else {
        _isFirstUsageLoad = false;
      }
      _lastRefreshTotalBytes = totalBytes;
      
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading sessions: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> disconnectSession(Map<String, dynamic> sessionData) async {
    if (_sessionRepository == null) return false;
    
    try {
      final success = await _sessionRepository!.disconnectSession(sessionData);
      if (success) {
        await loadActiveSessions();
      }
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error disconnecting session: $e');
      return false;
    }
  }

  // ==================== Hotspot Users ====================

  Future<void> loadHotspotUsers() async {
    if (_hotspotRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [NetworkProvider] Loading hotspot users...');
      final users = await _hotspotRepository!.fetchUsers();
      _hotspotUsers = users;
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading hotspot users: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadHotspotProfiles() async {
    if (_hotspotRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [NetworkProvider] Loading hotspot profiles...');
      final profiles = await _hotspotRepository!.fetchProfiles();
      _hotspotProfiles = profiles.map((p) => HotspotProfileModel.fromJson(p)).toList();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading hotspot profiles: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllConfigurations() async {
    if (_planConfigRepository == null) return;
    
    _setLoading(true);
    try {
      if (kDebugMode) print('📡 [NetworkProvider] Loading configurations...');
      await Future.wait([
        _loadRateLimits(),
        _loadDataLimits(),
        _loadValidityPeriods(),
        _loadIdleTimeouts(),
        _loadSharedUsers(),
        loadRouters(),
      ]);
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading configurations: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadRateLimits() async {
    if (_planConfigRepository == null) return;
    try {
      _rateLimits = await _planConfigRepository!.fetchRateLimits();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading rate limits: $e');
    }
  }

  Future<void> _loadDataLimits() async {
    if (_planConfigRepository == null) return;
    try {
      final config = await _planConfigRepository!.fetchDataLimits();
      _dataLimits = config;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading data limits: $e');
    }
  }

  // ==================== Plan Configurations ====================





  Future<void> _loadIdleTimeouts() async {
    if (_planConfigRepository == null) return;
    try {
      _idleTimeouts = await _planConfigRepository!.fetchIdleTimeouts();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading idle timeouts: $e');
    }
  }

  Future<void> _loadSharedUsers() async {
    if (_planConfigRepository == null) return;
    try {
      _sharedUsers = await _planConfigRepository!.fetchSharedUsers();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading shared users: $e');
    }
  }

  Future<void> createHotspotUser(Map<String, dynamic> userData) async {
    if (_hotspotRepository == null) return;
    try {
      await _hotspotRepository!.createUser(userData);
      await loadHotspotUsers();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error creating hotspot user: $e');
      rethrow;
    }
  }

  Future<void> updateHotspotUser(String username, Map<String, dynamic> userData) async {
    if (_hotspotRepository == null) return;
    try {
      await _hotspotRepository!.updateUser(username, userData);
      await loadHotspotUsers();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating hotspot user: $e');
      rethrow;
    }
  }

  Future<void> deleteHotspotUser(String username) async {
    if (_hotspotRepository == null) return;
    try {
      await _hotspotRepository!.deleteUser(username);
      await loadHotspotUsers();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting hotspot user: $e');
      rethrow;
    }
  }

  Future<void> createHotspotProfile(Map<String, dynamic> profileData) async {
    if (_hotspotRepository == null) return;
    try {
      await _hotspotRepository!.createProfile(profileData);
      await loadHotspotProfiles();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error creating hotspot profile: $e');
      rethrow;
    }
  }

  Future<void> updateHotspotProfile(String profileSlug, Map<String, dynamic> profileData) async {
    if (_hotspotRepository == null) return;
    try {
      await _hotspotRepository!.updateProfile(profileSlug, profileData);
      await loadHotspotProfiles();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating hotspot profile: $e');
      rethrow;
    }
  }

  Future<String> deleteHotspotProfile(String profileSlug) async {
    if (_hotspotRepository == null) return 'Error';
    try {
      final message = await _hotspotRepository!.deleteProfile(profileSlug);
      await loadHotspotProfiles();
      return message['message']?.toString() ?? 'Profile deleted';
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting hotspot profile: $e');
      rethrow;
    }
  }

  double get aggregateActiveDataUsage {
    return _activeDataUsage['total_bytes'] ?? 0;
  }

  double get aggregateTotalDataLimit {
    return _activeDataUsage['limit_bytes'] ?? 0;
  }

  double get totalAccumulatedGB {
    return _totalAccumulatedBytes / (1024 * 1024 * 1024);
  }

  // ==================== Router Assignments ====================

  List<String> getAssignedRouters(String username) {
    return _routerAssignments[username.toLowerCase()] ?? [];
  }

  Future<void> assignRoutersToWorker(String username, List<String> routerIds) async {
    _routerAssignments[username.toLowerCase()] = routerIds;
    await saveRouterAssignments();
    notifyListeners();
  }

  Future<void> loadRouterAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('router_assignments');
      if (jsonStr != null) {
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        _routerAssignments = decoded.map(
          (key, value) => MapEntry(key, List<String>.from(value as List))
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading router assignments: $e');
    }
  }

  Future<void> saveRouterAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('router_assignments', json.encode(_routerAssignments));
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error saving router assignments: $e');
    }
  }

  Future<void> _loadAccumulatedUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalAccumulatedBytes = prefs.getDouble('total_accumulated_usage_bytes') ?? 0;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading usage: $e');
    }
  }

  Future<void> _saveAccumulatedUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('total_accumulated_usage_bytes', _totalAccumulatedBytes);
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error saving usage: $e');
    }
  }

  Future<void> loadPlans() async {
    if (_planRepository == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      if (kDebugMode) print('📡 [NetworkProvider] Loading plans...');
      final plansData = await _planRepository!.fetchPlans();
      _plans = plansData.map<PlanModel>((data) => PlanModel.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error loading plans: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPlan(Map<String, dynamic> planData) async {
    if (_planRepository == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _planRepository!.createPlan(planData);
      await loadPlans();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error creating plan: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlan(String planId, Map<String, dynamic> planData) async {
    if (_planRepository == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _planRepository!.updatePlan(planId, planData);
      await loadPlans();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating plan: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePlan(String planId) async {
    if (_planRepository == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _planRepository!.deletePlan(planId);
      await loadPlans();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting plan: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== Plan Configurations (CRUD) ====================

  Future<void> createRateLimit(Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.createRateLimit(data);
      await _loadRateLimits();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error creating rate limit: $e');
      rethrow;
    }
  }

  Future<void> updateRateLimit(int id, Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.updateRateLimit(id, data);
      await _loadRateLimits();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating rate limit: $e');
      rethrow;
    }
  }

  Future<void> deleteRateLimit(int id) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.deleteRateLimit(id);
      await _loadRateLimits();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting rate limit: $e');
      rethrow;
    }
  }

  Future<void> createDataLimit(Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.createDataLimit(data);
      await _loadDataLimits();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error creating data limit: $e');
      rethrow;
    }
  }

  Future<void> updateDataLimit(int id, Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.updateDataLimit(id, data);
      await _loadDataLimits();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating data limit: $e');
      rethrow;
    }
  }

  Future<void> deleteDataLimit(int id) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.deleteDataLimit(id);
      await _loadDataLimits();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting data limit: $e');
      rethrow;
    }
  }
  Future<void> _loadValidityPeriods() async {
    if (_planConfigRepository == null) return;
    try {
      final config = await _planConfigRepository!.fetchValidityPeriods();
      _validityPeriods = config;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading validity periods: $e');
    }
  }
  Future<void> createValidityPeriod(Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.createValidityPeriod(data);
      await _loadValidityPeriods();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error creating validity period: $e');
      rethrow;
    }
  }

  Future<void> updateValidityPeriod(int id, Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.updateValidityPeriod(id, data);
      await _loadValidityPeriods();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating validity period: $e');
      rethrow;
    }
  }

  Future<void> deleteValidityPeriod(int id) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.deleteValidityPeriod(id);
      await _loadValidityPeriods();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting validity period: $e');
      rethrow;
    }
  }

  Future<void> createIdleTimeout(Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.createIdleTimeout(data);
      await _loadIdleTimeouts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error creating idle timeout: $e');
      rethrow;
    }
  }

  Future<void> updateIdleTimeout(int id, Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.updateIdleTimeout(id, data);
      await _loadIdleTimeouts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating idle timeout: $e');
      rethrow;
    }
  }

  Future<void> deleteIdleTimeout(int id) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.deleteIdleTimeout(id);
      await _loadIdleTimeouts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting idle timeout: $e');
      rethrow;
    }
  }

  Future<void> createSharedUsersConfig(Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.createSharedUsers(data);
      await _loadSharedUsers();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error creating shared user config: $e');
      rethrow;
    }
  }

  Future<void> updateSharedUsersConfig(int id, Map<String, dynamic> data) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.updateSharedUsers(id, data);
      await _loadSharedUsers();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error updating shared user config: $e');
      rethrow;
    }
  }

  Future<void> deleteSharedUsersConfig(int id) async {
    if (_planConfigRepository == null) return;
    try {
      await _planConfigRepository!.deleteSharedUsers(id);
      await _loadSharedUsers();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [NetworkProvider] Error deleting shared user config: $e');
      rethrow;
    }
  }
}
