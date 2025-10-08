import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/router_model.dart';
import '../models/plan_model.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/connectivity_service.dart';

class AppState with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PaymentService _paymentService = PaymentService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  List<UserModel> _users = [];
  List<RouterModel> _routers = [];
  List<PlanModel> _plans = [];
  List<TransactionModel> _transactions = [];
  double _walletBalance = 0.0;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;
  List<RouterModel> get routers => _routers;
  List<PlanModel> get plans => _plans;
  List<TransactionModel> get transactions => _transactions;
  double get walletBalance => _walletBalance;
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email, password);
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
    await _authService.logout();
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
    ]);
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
      _routers = await _connectivityService.getRouters();
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
      _walletBalance = await _paymentService.getWalletBalance();
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
}
