import 'package:dio/dio.dart';

/// Repository for partner profile and dashboard operations
class PartnerRepository {
  final Dio _dio;

  PartnerRepository({required Dio dio}) : _dio = dio;

  /// Fetch partner profile
  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final response = await _dio.get('/partner/profile/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Fetch profile error: $e');
      rethrow;
    }
  }

  /// Fetch dashboard data
  Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      final response = await _dio.get('/partner/dashboard/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Fetch dashboard error: $e');
      rethrow;
    }
  }

  /// Update partner profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      await _dio.put('/partner/update/', data: profileData);
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
}
