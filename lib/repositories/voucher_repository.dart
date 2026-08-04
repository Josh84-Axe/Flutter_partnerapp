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
      if (kDebugMode) debugPrint('🎫 [VoucherRepository] Fetching tickets. Filter plan: $planId');
      
      final response = await _dio.get(
        '/plans/tickets/',
        queryParameters: planId != null ? {'plan': int.tryParse(planId) ?? planId} : null,
      );
      
      final responseData = response.data;
      if (kDebugMode) debugPrint('🎫 [VoucherRepository] Raw response data: $responseData');
      if (responseData is Map && responseData['data'] is List) {
        final List list = responseData['data'];
        return list.map((json) {
          final model = VoucherModel.fromJson(json);
          if (kDebugMode) debugPrint('🎫 [VoucherRepository] Parsed ticket: ${model.code} (Plan: ${model.planId})');
          return model;
        }).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [VoucherRepository] Fetch tickets error: $e');
      rethrow;
    }
  }

  /// Generate a batch of tickets for a plan
  Future<List<VoucherModel>> generateVouchers(String planId, int quantity) async {
    try {
      if (kDebugMode) debugPrint('🎫 [VoucherRepository] Generating $quantity tickets for plan: $planId');
      final response = await _dio.post(
        '/plans/tickets/generate/',
        data: {
          'plan': int.tryParse(planId) ?? planId,
          'count': quantity, // New API uses 'count'
        },
      );
      
      final responseData = response.data;
      if (kDebugMode) debugPrint('🎫 [VoucherRepository] Raw generation response: $responseData');
      if (responseData is Map && responseData['data'] is List) {
        final List list = responseData['data'];
        return list.map((json) => VoucherModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('❌ [VoucherRepository] Generate tickets error: $e');
      rethrow;
    }
  }

  /// Get export URL for tickets (PDF or CSV)
  String getExportUrl(String planId, {String format = 'pdf'}) {
    // Note: The exact export URL for tickets is still being verified.
    // We'll use the most likely format based on the new endpoints.
    return '/plans/tickets/export/?plan=$planId&format=$format';
  }
}
