import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_notification_model.dart';

class LocalNotificationService {
  static const String _notificationsKey = 'local_notifications';
  static const String _lastTransactionIdKey = 'last_transaction_id';
  static const String _lastPayoutIdKey = 'last_payout_id';
  static const String _lastUserCountKey = 'last_user_count';
  static const int _maxNotifications = 100; // Keep last 100 notifications
  
  final List<LocalNotification> _notifications = [];
  final _notificationController = StreamController<LocalNotification>.broadcast();
  Timer? _pollingTimer;
  
  // Callbacks for data fetching (injected from AppState)
  Future<List<dynamic>> Function()? fetchTransactions;
  Future<List<dynamic>> Function()? fetchPayouts;
  Future<double> Function()? fetchWalletBalance;
  Future<int> Function()? fetchUserCount;
  
  Stream<LocalNotification> get notificationStream => _notificationController.stream;
  List<LocalNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  LocalNotificationService();

  /// Initialize the service and start polling
  Future<void> initialize({
    required Future<List<dynamic>> Function() onFetchTransactions,
    required Future<List<dynamic>> Function() onFetchPayouts,
    required Future<double> Function() onFetchWalletBalance,
    required Future<int> Function() onFetchUserCount,
  }) async {
    fetchTransactions = onFetchTransactions;
    fetchPayouts = onFetchPayouts;
    fetchWalletBalance = onFetchWalletBalance;
    fetchUserCount = onFetchUserCount;
    
    await _loadNotifications();
    startPolling();
  }

  /// Start polling for changes
  void startPolling({Duration interval = const Duration(minutes: 5)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) => _checkForUpdates());
    if (kDebugMode) print('🔔 [LocalNotificationService] Polling started (${interval.inMinutes} min)');
  }

  /// Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    if (kDebugMode) print('🔔 [LocalNotificationService] Polling stopped');
  }

  /// Check for updates across all monitors
  Future<void> _checkForUpdates() async {
    if (kDebugMode) print('🔔 [LocalNotificationService] Checking for updates...');
    
    try {
      await Future.wait([
        _checkTransactions(),
        _checkPayouts(),
        _checkBalance(),
        _checkUsers(),
      ]);
    } catch (e) {
      if (kDebugMode) print('❌ [LocalNotificationService] Error checking updates: $e');
    }
  }

  /// Monitor new transactions
  Future<void> _checkTransactions() async {
    if (fetchTransactions == null) return;
    
    try {
      final transactions = await fetchTransactions!();
      if (transactions.isEmpty) return;
      
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString(_lastTransactionIdKey);
      final latestId = transactions.first['id']?.toString();
      
      if (lastId != null && latestId != null && lastId != latestId) {
        // New transaction detected
        final amount = transactions.first['amount'] ?? 0;
        await _addNotification(
          title: 'New Payment Received',
          message: 'You received a payment of \$$amount',
          type: 'transaction',
          data: transactions.first,
        );
      }
      
      if (latestId != null) {
        await prefs.setString(_lastTransactionIdKey, latestId);
      }
    } catch (e) {
      if (kDebugMode) print('❌ [LocalNotificationService] Transaction check error: $e');
    }
  }

  /// Monitor payout status changes
  Future<void> _checkPayouts() async {
    if (fetchPayouts == null) return;
    
    try {
      final payouts = await fetchPayouts!();
      if (payouts.isEmpty) return;
      
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString(_lastPayoutIdKey);
      final latestPayout = payouts.first;
      final latestId = latestPayout['id']?.toString();
      final status = latestPayout['status']?.toString().toLowerCase();
      
      if (lastId != null && latestId != null && lastId != latestId) {
        // Payout status changed
        final amount = latestPayout['amount'] ?? 0;
        String message = 'Your payout of \$$amount is $status';
        
        await _addNotification(
          title: 'Payout Update',
          message: message,
          type: 'payout',
          data: latestPayout,
        );
      }
      
      if (latestId != null) {
        await prefs.setString(_lastPayoutIdKey, latestId);
      }
    } catch (e) {
      if (kDebugMode) print('❌ [LocalNotificationService] Payout check error: $e');
    }
  }

  /// Monitor wallet balance for low balance warnings
  Future<void> _checkBalance() async {
    if (fetchWalletBalance == null) return;
    
    try {
      final balance = await fetchWalletBalance!();
      const threshold = 10.0; // Alert if balance < $10
      
      if (balance < threshold) {
        // Check if we already sent this alert recently (within 24 hours)
        final recentAlert = _notifications.any((n) =>
          n.type == 'balance' &&
          DateTime.now().difference(n.timestamp).inHours < 24
        );
        
        if (!recentAlert) {
          await _addNotification(
            title: 'Low Balance Alert',
            message: 'Your wallet balance is low: \$${balance.toStringAsFixed(2)}',
            type: 'balance',
            data: {'balance': balance},
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ [LocalNotificationService] Balance check error: $e');
    }
  }

  /// Monitor new hotspot users
  Future<void> _checkUsers() async {
    if (fetchUserCount == null) return;
    
    try {
      final currentCount = await fetchUserCount!();
      final prefs = await SharedPreferences.getInstance();
      final lastCount = prefs.getInt(_lastUserCountKey) ?? currentCount;
      
      if (currentCount > lastCount) {
        final newUsers = currentCount - lastCount;
        await _addNotification(
          title: 'New Users Connected',
          message: '$newUsers new user${newUsers > 1 ? 's' : ''} connected',
          type: 'user',
          data: {'count': newUsers},
        );
      }
      
      await prefs.setInt(_lastUserCountKey, currentCount);
    } catch (e) {
      if (kDebugMode) print('❌ [LocalNotificationService] User check error: $e');
    }
  }

  /// Add a new notification
  Future<void> _addNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final notification = LocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      data: data,
    );
    
    _notifications.insert(0, notification);
    
    // Limit notification count
    if (_notifications.length > _maxNotifications) {
      _notifications.removeRange(_maxNotifications, _notifications.length);
    }
    
    await _saveNotifications();
    _notificationController.add(notification);
    
    if (kDebugMode) print('🔔 [LocalNotificationService] New notification: $title');
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
  }

  /// Load notifications from local storage
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notificationsKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _notifications.clear();
        _notifications.addAll(
          jsonList.map((json) => LocalNotification.fromJson(json)).toList()
        );
        if (kDebugMode) print('🔔 [LocalNotificationService] Loaded ${_notifications.length} notifications');
      }
    } catch (e) {
      if (kDebugMode) print('❌ [LocalNotificationService] Load error: $e');
    }
  }

  /// Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, json.encode(jsonList));
    } catch (e) {
      if (kDebugMode) print('❌ [LocalNotificationService] Save error: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _pollingTimer?.cancel();
    _notificationController.close();
  }
}
