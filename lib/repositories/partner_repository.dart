import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for partner profile and dashboard operations
class PartnerRepository {
  final Dio _dio;

  PartnerRepository({required Dio dio}) : _dio = dio;

  /// Fetch partner profile
  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      if (kDebugMode) print('👤 [PartnerRepository] Fetching partner profile');
      final response = await _dio.get('/partner/profile/');
      if (kDebugMode) print('✅ [PartnerRepository] Profile fetched successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Fetch profile error: $e');
      rethrow;
    }
  }

  /// Fetch dashboard data
  Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      if (kDebugMode) print('📊 [PartnerRepository] Fetching dashboard data');
      final response = await _dio.get('/partner/dashboard/');
      if (kDebugMode) print('✅ [PartnerRepository] Dashboard response status: ${response.statusCode}');
      if (kDebugMode) print('📦 [PartnerRepository] Dashboard response data: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Fetch dashboard error: $e');
      rethrow;
    }
  }

  /// Update partner profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      if (kDebugMode) print('✏️ [PartnerRepository] Updating partner profile');
      if (kDebugMode) print('📦 [PartnerRepository] Profile data: $profileData');
      await _dio.put('/partner/profile/update/', data: profileData);
      if (kDebugMode) print('✅ [PartnerRepository] Profile updated successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Update profile error: $e');
      return false;
    }
  }


  /// Login with email and password
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      if (kDebugMode) print('🔐 [PartnerRepository] Logging in user: $email');
      final response = await _dio.post(
        '/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (kDebugMode) print('✅ [PartnerRepository] Login successful');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Login error: $e');
      rethrow;
    }
  }

  /// Fetch available countries
  Future<List<Map<String, String>>> fetchCountries() async {
    try {
      if (kDebugMode) print('🌍 [PartnerRepository] Fetching countries');
      final response = await _dio.get('/partner/countries/');
      final responseData = response.data;
      List<dynamic> data = [];
      
      if (responseData is Map) {
        if (responseData['data'] is List) {
          data = responseData['data'] as List;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          data = responseData['data']['results'] as List;
        } else if (responseData['results'] is List) {
          data = responseData['results'] as List;
        }
      } else if (responseData is List) {
        data = responseData as List;
      }

      return data.map<Map<String, String>>((item) => {
        'code': item['code']?.toString() ?? '',
        'name': item['name']?.toString() ?? '',
      }).toList();
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Fetch countries error: $e');
      return [];
    }
  }

  /// Fetch available payment methods
  Future<List<String>> fetchPaymentMethods() async {
    try {
      if (kDebugMode) print('💳 [PartnerRepository] Fetching payment methods');
      final response = await _dio.get('/partner/payment-methods/');
      final responseData = response.data;
      List<dynamic> data = [];

      if (responseData is Map) {
        if (responseData['data'] is List) {
          data = responseData['data'] as List;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          data = responseData['data']['results'] as List;
        } else if (responseData['results'] is List) {
          data = responseData['results'] as List;
        }
      } else if (responseData is List) {
        data = responseData as List;
      }
      
      return data.map((item) => item['name']?.toString() ?? '').toList();
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Fetch payment methods error: $e');
      return [];
    }
  }



  /// Fetch counters balance (Total, Online, Assigned Revenue)
  Future<Map<String, dynamic>?> fetchCountersBalance() async {
    try {
      if (kDebugMode) print('💰 [PartnerRepository] Fetching counters balance');
      final response = await _dio.get('/partner/counters/balance/');
      if (kDebugMode) print('✅ [PartnerRepository] Raw response: ${response.data}');
      
      final responseData = response.data as Map<String, dynamic>?;
      
      // Extract 'data' field from wrapped response
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (kDebugMode) print('✅ [PartnerRepository] Extracted data: $data');
        return data;
      }
      
      if (kDebugMode) print('⚠️ [PartnerRepository] No data field in response');
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Fetch counters balance error: $e');
      return null;
    }
  }

  /// Fetch wallet balance
  Future<Map<String, dynamic>?> fetchWalletBalance() async {
    try {
      if (kDebugMode) print('💳 [PartnerRepository] Fetching wallet balance');
      final response = await _dio.get('/partner/wallet/balance/');
      if (kDebugMode) print('✅ [PartnerRepository] Raw response: ${response.data}');
      
      final responseData = response.data as Map<String, dynamic>?;
      
      // Extract 'data' field from wrapped response
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (kDebugMode) print('✅ [PartnerRepository] Extracted data: $data');
        return data;
      }
      
      if (kDebugMode) print('⚠️ [PartnerRepository] No data field in response');
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Fetch wallet balance error: $e');
      return null;
    }
  }
  /// Fetch available report types
  Future<List<String>> fetchReportTypes() async {
    try {
      if (kDebugMode) print('📊 [PartnerRepository] Fetching report types');
      final response = await _dio.get('/partner/report-types/');
      final responseData = response.data;
      List<dynamic> data = [];

      if (responseData is Map) {
        if (responseData['data'] is List) {
          data = responseData['data'] as List;
        } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
          data = responseData['data']['results'] as List;
        } else if (responseData['results'] is List) {
          data = responseData['results'] as List;
        }
      } else if (responseData is List) {
        data = responseData as List;
      }
      
      return data.map((item) => item['name']?.toString() ?? '').toList();
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Fetch report types error: $e');
      return [];
    }
  }
  /// Check subscription status
  Future<Map<String, dynamic>?> checkSubscriptionStatus() async {
    try {
      if (kDebugMode) print('📦 [PartnerRepository] Checking subscription status');
      final response = await _dio.get('/partner/subscription-plans/check/');
      if (kDebugMode) print('✅ [PartnerRepository] Subscription status response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Check subscription status error: $e');
      return null;
    }
  }
}
