import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/voucher_model.dart';

class VoucherRepository {
  final Dio _dio;

  VoucherRepository({required Dio dio}) : _dio = dio;

  /// Fetch vouchers/tickets
  /// Supports filtering by planId via query parameter
  Future<List<VoucherModel>> fetchVouchers(String? planId) async {
    try {
      if (kDebugMode) print('🎫 [VoucherRepository] Fetching tickets. Filter plan: $planId');
      
      final response = await _dio.get(
        '/partner/plans/tickets/',
        queryParameters: planId != null ? {'plan': planId} : null,
      );
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        final List list = responseData['data'];
        return list.map((json) => VoucherModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [VoucherRepository] Fetch tickets error: $e');
      rethrow;
    }
  }

  /// Generate a batch of tickets for a plan
  Future<List<VoucherModel>> generateVouchers(String planId, int quantity) async {
    try {
      if (kDebugMode) print('🎫 [VoucherRepository] Generating $quantity tickets for plan: $planId');
      final response = await _dio.post(
        '/partner/plans/tickets/generate/',
        data: {
          'plan': planId,
          'count': quantity, // New API uses 'count'
        },
      );
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        final List list = responseData['data'];
        return list.map((json) => VoucherModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [VoucherRepository] Generate tickets error: $e');
      rethrow;
    }
  }

  /// Get export URL for tickets (PDF or CSV)
  String getExportUrl(String planId, {String format = 'pdf'}) {
    // Note: The exact export URL for tickets is still being verified.
    // We'll use the most likely format based on the new endpoints.
    return '/partner/plans/tickets/export/?plan=$planId&format=$format';
  }
}
