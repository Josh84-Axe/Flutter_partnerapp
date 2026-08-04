import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Repository for additional device operations
class AdditionalDeviceRepository {
  final Dio _dio;

  AdditionalDeviceRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of additional devices
  Future<List<dynamic>> fetchAdditionalDevices() async {
    try {
      final response = await _dio.get('/additional-devices/list/');
      final responseData = response.data;
      
      if (responseData is Map) {
         if (responseData['data'] is List) {
           return responseData['data'] as List;
         } else if (responseData['data'] is Map && responseData['data']['results'] is List) {
           return responseData['data']['results'] as List;
         } else if (responseData['results'] is List) {
           return responseData['results'] as List;
         }
      } else if (responseData is List) {
         return responseData;
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch additional devices error: $e');
      rethrow;
    }
  }

  /// Create additional device
  Future<Map<String, dynamic>?> createAdditionalDevice(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/additional-devices/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Create additional device error: $e');
      rethrow;
    }
  }

  /// Get additional device details
  Future<Map<String, dynamic>?> getAdditionalDeviceDetails(int id) async {
    try {
      final response = await _dio.get('/additional-devices/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Get additional device details error: $e');
      rethrow;
    }
  }

  /// Update additional device
  Future<Map<String, dynamic>?> updateAdditionalDevice(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/additional-devices/$id/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) debugPrint('Update additional device error: $e');
      rethrow;
    }
  }

  /// Delete additional device
  Future<bool> deleteAdditionalDevice(int id) async {
    try {
      await _dio.delete('/additional-devices/$id/delete/');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete additional device error: $e');
      return false;
    }
  }
}
