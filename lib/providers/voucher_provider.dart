import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/voucher_model.dart';
import '../repositories/voucher_repository.dart';

class VoucherProvider with ChangeNotifier {
  final VoucherRepository _repository;
  
  Map<String, List<VoucherModel>> _planVouchers = {};
  bool _isLoading = false;
  String? _error;

  VoucherProvider({required VoucherRepository repository}) : _repository = repository;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<VoucherModel> getVouchersForPlan(String planId) => _planVouchers[planId] ?? [];

  Future<void> loadVouchers(String planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vouchers = await _repository.fetchVouchers(planId);
      // Safeguard: Filter by planId on frontend in case backend returns unfiltered list
      final filtered = vouchers.where((v) => v.planId == planId).toList();
      if (kDebugMode) print('🎫 [VoucherProvider] Loaded ${vouchers.length} vouchers, ${filtered.length} matched plan $planId');
      _planVouchers[planId] = filtered;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateVouchers(String planId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newVouchers = await _repository.generateVouchers(planId, quantity);
      // Safeguard: Also filter new vouchers to ensure they belong to this plan
      final filteredNew = newVouchers.where((v) => v.planId == planId).toList();
      if (kDebugMode) print('🎫 [VoucherProvider] Generated ${newVouchers.length} vouchers, ${filteredNew.length} matched plan $planId');
      
      final currentVouchers = _planVouchers[planId] ?? [];
      _planVouchers[planId] = [...filteredNew, ...currentVouchers];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getExportUrl(String planId, {String format = 'pdf'}) {
    return _repository.getExportUrl(planId, format: format);
  }
}
