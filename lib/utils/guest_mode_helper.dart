import 'package:flutter/material.dart';
import '../models/router_model.dart';
import '../models/user_model.dart';
import 'currency_utils.dart';

/// Helper class for guest mode functionality
/// Generates mock data for demo purposes
class GuestModeHelper {
  /// Create a guest user based on locale
  static UserModel createGuestUser({String? countryCode}) {
    final country = _getCountryFromCode(countryCode ?? 'GH');
    
    return UserModel(
      id: 'guest-user',
      name: 'Guest User',
      email: 'guest@demo.com',
      role: 'Partner',
      isActive: true,
      createdAt: DateTime.now(),
      phone: '+1234567890',
      address: '123 Demo Street',
      city: _getCityForCountry(country),
      country: country,
      numberOfRouters: 3,
    );
  }

  /// Generate demo routers
  static List<RouterModel> generateDemoRouters() {
    return [
      RouterModel(
        id: 'demo-router-1',
        name: 'Main Office Router',
        slug: 'main-office-router',
        status: 'online',
        connectedUsers: 12,
        dataUsageGB: 45.8,
        uptimeHours: 720,
        lastSeen: DateTime.now(),
      ),
      RouterModel(
        id: 'demo-router-2',
        name: 'Branch Router',
        slug: 'branch-router',
        status: 'issues',
        connectedUsers: 5,
        dataUsageGB: 23.4,
        uptimeHours: 680,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      RouterModel(
        id: 'demo-router-3',
        name: 'Backup Router',
        slug: 'backup-router',
        status: 'offline',
        connectedUsers: 0,
        dataUsageGB: 0.0,
        uptimeHours: 0,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  /// Generate demo customers (as UserModel objects)
  static List<UserModel> generateDemoCustomers() {
    return [
      UserModel(
        id: 'demo-cust-1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1234567891',
        role: 'Customer',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      UserModel(
        id: 'demo-cust-2',
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phone: '+1234567892',
        role: 'Customer',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: 'demo-cust-3',
        name: 'Mike Johnson',
        email: 'mike.j@example.com',
        phone: '+1234567893',
        role: 'Customer',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      UserModel(
        id: 'demo-cust-4',
        name: 'Sarah Williams',
        email: 'sarah.w@example.com',
        phone: '+1234567894',
        role: 'Customer',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'demo-cust-5',
        name: 'David Brown',
        email: 'david.b@example.com',
        phone: '+1234567895',
        role: 'Customer',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// Generate demo transactions based on locale
  static List<Map<String, dynamic>> generateDemoTransactions(String country) {
    final currency = CurrencyUtils.getCurrencyCode(country);
    final now = DateTime.now();
    
    return [
      {
        'id': 'demo-txn-1',
        'type': 'plan_purchase',
        'amount': 50.0,
        'currency': currency,
        'status': 'completed',
        'customer_name': 'John Doe',
        'plan_name': 'Premium Plan',
        'description': 'Premium Plan purchase by John Doe',
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'demo-txn-2',
        'type': 'plan_purchase',
        'amount': 20.0,
        'currency': currency,
        'status': 'completed',
        'customer_name': 'Jane Smith',
        'plan_name': 'Basic Plan',
        'description': 'Basic Plan purchase by Jane Smith',
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 'demo-txn-3',
        'type': 'plan_purchase',
        'amount': 35.0,
        'currency': currency,
        'status': 'completed',
        'customer_name': 'Mike Johnson',
        'plan_name': 'Standard Plan',
        'description': 'Standard Plan purchase by Mike Johnson',
        'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 'demo-txn-4',
        'type': 'withdrawal',
        'amount': 100.0,
        'currency': currency,
        'status': 'pending',
        'description': 'Withdrawal to bank account',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
  }

  /// Generate demo wallet data
  static Map<String, dynamic> generateDemoWallet(String country) {
    final currency = CurrencyUtils.getCurrencyCode(country);
    
    return {
      'balance': 250.0,
      'currency': currency,
      'pending_balance': 50.0,
      'total_earned': 1250.0,
      'total_withdrawn': 1000.0,
    };
  }

  /// Generate demo dashboard stats
  static Map<String, dynamic> generateDemoStats() {
    return {
      'total_customers': 45,
      'active_customers': 38,
      'total_revenue': 2500.0,
      'active_sessions': 12,
      'routers_online': 2,
      'routers_total': 3,
    };
  }

  /// Check if an action is allowed in guest mode
  static bool canPerformAction(BuildContext context, {
    required bool isGuestMode,
    required VoidCallback onRegisterRequired,
  }) {
    if (isGuestMode) {
      onRegisterRequired();
      return false;
    }
    return true;
  }

  /// Get country name from country code
  static String _getCountryFromCode(String code) {
    switch (code.toUpperCase()) {
      case 'GH':
        return 'Ghana';
      case 'NG':
        return 'Nigeria';
      case 'KE':
        return 'Kenya';
      case 'ZA':
        return 'South Africa';
      case 'UG':
        return 'Uganda';
      default:
        return 'Ghana';
    }
  }

  /// Get demo city for country
  static String _getCityForCountry(String country) {
    switch (country.toLowerCase()) {
      case 'ghana':
        return 'Accra';
      case 'nigeria':
        return 'Lagos';
      case 'kenya':
        return 'Nairobi';
      case 'south africa':
        return 'Johannesburg';
      case 'uganda':
        return 'Kampala';
      default:
        return 'Accra';
    }
  }
}
