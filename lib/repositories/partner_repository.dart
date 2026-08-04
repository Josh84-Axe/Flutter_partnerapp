import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Repository for partner profile and dashboard operations
class PartnerRepository {
  final Dio _dio;

  PartnerRepository({required Dio dio}) : _dio = dio;

  /// Fetch partner profile
  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      if (kDebugMode) debugPrint('👤 [PartnerRepository] Fetching partner profile');
      final response = await _dio.get('/profile/');
      if (kDebugMode) debugPrint('✅ [PartnerRepository] Profile fetched successfully');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Fetch profile error: $e');
      rethrow;
    }
  }

  /// Fetch dashboard data
  Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      if (kDebugMode) debugPrint('📊 [PartnerRepository] Fetching dashboard data');
      final response = await _dio.get('/dashboard/');
      if (kDebugMode) debugPrint('✅ [PartnerRepository] Dashboard response status: ${response.statusCode}');
      if (kDebugMode) debugPrint('📦 [PartnerRepository] Dashboard response data: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Fetch dashboard error: $e');
      rethrow;
    }
  }

  /// Update partner profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      if (kDebugMode) debugPrint('✏️ [PartnerRepository] Updating partner profile');
      
      // Transform keys to match API expectations
      final Map<String, dynamic> data = Map<String, dynamic>.from(profileData);
      
      if (data.containsKey('address')) {
        data['addresse'] = data.remove('address');
      }
      if (data.containsKey('number_of_routers')) {
        data['number_of_router'] = data.remove('number_of_routers');
      }

      // Handle image upload if portal_hero_image is a local file path
      dynamic requestData;
      bool isMultipart = false;

      if (data['portal_hero_image'] != null) {
        final heroImage = data['portal_hero_image'];
        
        if (heroImage is XFile) {
          if (kIsWeb) {
            final bytes = await heroImage.readAsBytes();
            data['portal_hero_image'] = MultipartFile.fromBytes(
              bytes,
              filename: heroImage.name,
            );
          } else {
            data['portal_hero_image'] = await MultipartFile.fromFile(heroImage.path);
          }
          isMultipart = true;
        } else if (heroImage is String && heroImage.startsWith('http')) {
          // If it's already a URL, we don't need to send it back to the update endpoint
          data.remove('portal_hero_image');
        } else if (heroImage is String) {
          // Backward compatibility for path strings
          if (!heroImage.startsWith('http')) {
            data['portal_hero_image'] = await MultipartFile.fromFile(heroImage);
            isMultipart = true;
          }
        }
      }

      if (isMultipart) {
        requestData = FormData.fromMap(data);
      } else {
        requestData = data;
      }

      if (kDebugMode) debugPrint('📦 [PartnerRepository] Request data: $requestData');
      
      await _dio.put('/profile/update/', data: requestData);
      if (kDebugMode) debugPrint('✅ [PartnerRepository] Profile updated successfully');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Update profile error: $e');
      if (e is DioException) {
        if (kDebugMode) debugPrint('❌ [PartnerRepository] Detail: ${e.response?.data}');
      }
      return false;
    }
  }


  /// Login with email and password
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      if (kDebugMode) debugPrint('🔐 [PartnerRepository] Logging in user: $email');
      final response = await _dio.post(
        '/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (kDebugMode) debugPrint('✅ [PartnerRepository] Login successful');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Login error: $e');
      rethrow;
    }
  }

  /// Fetch available countries
  Future<List<Map<String, String>>> fetchCountries() async {
    try {
      if (kDebugMode) debugPrint('🌍 [PartnerRepository] Fetching countries');
      final response = await _dio.get('/countries/');
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
        data = responseData;
      }

      return data.map<Map<String, String>>((item) => {
        'code': item['code']?.toString() ?? '',
        'name': item['name']?.toString() ?? '',
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Fetch countries error: $e');
      return [];
    }
  }

  /// Fetch available payment methods
  Future<List<String>> fetchPaymentMethods() async {
    try {
      if (kDebugMode) debugPrint('💳 [PartnerRepository] Fetching payment methods');
      final response = await _dio.get('/payment-methods/');
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
        data = responseData;
      }
      
      return data.map((item) => item['name']?.toString() ?? '').toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Fetch payment methods error: $e');
      return [];
    }
  }



  /// Fetch counters balance (Total, Online, Assigned Revenue)
  Future<Map<String, dynamic>?> fetchCountersBalance() async {
    try {
      if (kDebugMode) debugPrint('💰 [PartnerRepository] Fetching counters balance');
      final response = await _dio.get('/counters/balance/');
      if (kDebugMode) debugPrint('✅ [PartnerRepository] Raw response: ${response.data}');
      
      final responseData = response.data as Map<String, dynamic>?;
      
      // Extract 'data' field from wrapped response
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (kDebugMode) debugPrint('✅ [PartnerRepository] Extracted data: $data');
        return data;
      }
      
      if (kDebugMode) debugPrint('⚠️ [PartnerRepository] No data field in response');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Fetch counters balance error: $e');
      return null;
    }
  }

  /// Fetch wallet balance
  Future<Map<String, dynamic>?> fetchWalletBalance() async {
    try {
      if (kDebugMode) debugPrint('💳 [PartnerRepository] Fetching wallet balance');
      final response = await _dio.get('/wallet/balance/');
      if (kDebugMode) debugPrint('✅ [PartnerRepository] Raw response: ${response.data}');
      
      final responseData = response.data as Map<String, dynamic>?;
      
      // Extract 'data' field from wrapped response
      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (kDebugMode) debugPrint('✅ [PartnerRepository] Extracted data: $data');
        return data;
      }
      
      if (kDebugMode) debugPrint('⚠️ [PartnerRepository] No data field in response');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Fetch wallet balance error: $e');
      return null;
    }
  }
  /// Fetch available report types
  Future<List<String>> fetchReportTypes() async {
    try {
      if (kDebugMode) debugPrint('📊 [PartnerRepository] Fetching report types');
      final response = await _dio.get('/report-types/');
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
        data = responseData;
      }
      
      return data.map((item) => item['name']?.toString() ?? '').toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Fetch report types error: $e');
      return [];
    }
  }
  /// Check subscription status
  Future<Map<String, dynamic>?> checkSubscriptionStatus() async {
    try {
      if (kDebugMode) debugPrint('📦 [PartnerRepository] Checking subscription status');
      final response = await _dio.get('/subscription-plans/check/');
      if (kDebugMode) debugPrint('✅ [PartnerRepository] Subscription status response: ${response.data}');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [PartnerRepository] Check subscription status error: $e');
      return null;
    }
  }
}
