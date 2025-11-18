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
      if (kDebugMode) print('✅ [PartnerRepository] Profile response status: ${response.statusCode}');
      if (kDebugMode) print('📦 [PartnerRepository] Profile response data: ${response.data}');
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
      await _dio.put('/partner/update/', data: profileData);
      if (kDebugMode) print('✅ [PartnerRepository] Profile updated successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [PartnerRepository] Update profile error: $e');
      return false;
    }
  }
}
