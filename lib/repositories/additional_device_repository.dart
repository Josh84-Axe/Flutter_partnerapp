import 'package:dio/dio.dart';

/// Repository for additional device operations
class AdditionalDeviceRepository {
  final Dio _dio;

  AdditionalDeviceRepository({required Dio dio}) : _dio = dio;

  /// Fetch list of additional devices
  Future<List<dynamic>> fetchAdditionalDevices() async {
    try {
      final response = await _dio.get('/partner/additional-devices/');
      final responseData = response.data;
      
      if (responseData is Map && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      
      return [];
    } catch (e) {
      print('Fetch additional devices error: $e');
      rethrow;
    }
  }

  /// Create additional device
  Future<Map<String, dynamic>?> createAdditionalDevice(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/partner/additional-devices/create/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Create additional device error: $e');
      rethrow;
    }
  }

  /// Get additional device details
  Future<Map<String, dynamic>?> getAdditionalDeviceDetails(int id) async {
    try {
      final response = await _dio.get('/partner/additional-devices/$id/');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Get additional device details error: $e');
      rethrow;
    }
  }

  /// Update additional device
  Future<Map<String, dynamic>?> updateAdditionalDevice(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/partner/additional-devices/$id/', data: data);
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Update additional device error: $e');
      rethrow;
    }
  }

  /// Delete additional device
  Future<bool> deleteAdditionalDevice(int id) async {
    try {
      await _dio.delete('/partner/additional-devices/$id/delete/');
      return true;
    } catch (e) {
      print('Delete additional device error: $e');
      return false;
    }
  }
}
