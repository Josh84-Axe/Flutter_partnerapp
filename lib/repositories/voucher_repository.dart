import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/voucher_model.dart';

class VoucherRepository {
  final Dio _dio;

  VoucherRepository({required Dio dio}) : _dio = dio;

  /// Fetch vouchers for a specific plan
  Future<List<VoucherModel>> fetchVouchers(String planId) async {
    try {
      if (kDebugMode) print('🎫 [VoucherRepository] Fetching vouchers for plan: $planId');
      final response = await _dio.get('/partner/plans/$planId/vouchers/');
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        final List list = responseData['data'];
        return list.map((json) => VoucherModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [VoucherRepository] Fetch vouchers error: $e');
      rethrow;
    }
  }

  /// Generate a batch of vouchers for a plan
  Future<List<VoucherModel>> generateVouchers(String planId, int quantity) async {
    try {
      if (kDebugMode) print('🎫 [VoucherRepository] Generating $quantity vouchers for plan: $planId');
      final response = await _dio.post(
        '/partner/plans/$planId/vouchers/generate/',
        data: {'quantity': quantity},
      );
      
      final responseData = response.data;
      if (responseData is Map && responseData['data'] is List) {
        final List list = responseData['data'];
        return list.map((json) => VoucherModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ [VoucherRepository] Generate vouchers error: $e');
      rethrow;
    }
  }

  /// Get export URL for vouchers (PDF or CSV)
  String getExportUrl(String planId, {String format = 'pdf'}) {
    // Assuming the base URL is already configured in Dio or ApiConfig
    return '/partner/plans/$planId/vouchers/export/?format=$format';
  }
}
