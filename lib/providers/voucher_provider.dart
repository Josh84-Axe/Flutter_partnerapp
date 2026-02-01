import 'package:flutter/material.dart';
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
      _planVouchers[planId] = vouchers;
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
      final currentVouchers = _planVouchers[planId] ?? [];
      _planVouchers[planId] = [...newVouchers, ...currentVouchers];
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
