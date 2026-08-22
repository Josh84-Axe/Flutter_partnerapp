import 'package:flutter/foundation.dart';
import '../models/voucher_model.dart';
import '../repositories/voucher_repository.dart';

class VoucherProvider with ChangeNotifier {
  final VoucherRepository _repository;
  
  final Map<String, List<VoucherModel>> _planVouchers = {};
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
      // Safeguard 1: Filter by planId on frontend in case backend returns unfiltered list
      final filtered = vouchers.where((v) => v.planId == planId).toList();
      
      // Safeguard 2: Deduplicate by unique voucher code/id to prevent duplicate UI items
      final Map<String, VoucherModel> uniqueMap = {};
      for (var v in filtered) {
        final key = v.code.isNotEmpty ? v.code : v.id;
        if (key.isNotEmpty) {
          uniqueMap[key] = v;
        }
      }
      
      final deduplicated = uniqueMap.values.toList();
      if (kDebugMode) debugPrint('🎫 [VoucherProvider] Loaded ${vouchers.length} vouchers, ${deduplicated.length} unique matched plan $planId');
      _planVouchers[planId] = deduplicated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<VoucherModel>> generateVouchers(String planId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newVouchers = await _repository.generateVouchers(planId, quantity);
      // Safeguard 1: Also filter new vouchers to ensure they belong to this plan
      final filteredNew = newVouchers.where((v) => v.planId == planId).toList();
      
      final currentVouchers = _planVouchers[planId] ?? [];
      
      // Safeguard 2: Deduplicate combined list by unique voucher code/id
      final Map<String, VoucherModel> uniqueMap = {};
      for (var v in currentVouchers) {
        final key = v.code.isNotEmpty ? v.code : v.id;
        if (key.isNotEmpty) uniqueMap[key] = v;
      }
      for (var v in filteredNew) {
        final key = v.code.isNotEmpty ? v.code : v.id;
        if (key.isNotEmpty) uniqueMap[key] = v;
      }

      final deduplicatedCombined = uniqueMap.values.toList();
      if (kDebugMode) debugPrint('🎫 [VoucherProvider] Generated ${newVouchers.length} vouchers, total unique: ${deduplicatedCombined.length}');
      
      _planVouchers[planId] = deduplicatedCombined;
      
      return filteredNew;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getExportUrl(String planId, {String format = 'pdf'}) {
    return _repository.getExportUrl(planId, format: format);
  }
}
