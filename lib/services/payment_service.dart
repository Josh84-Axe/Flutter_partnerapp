import '../models/plan_model.dart';
import '../models/transaction_model.dart';

class PaymentService {
  Future<List<PlanModel>> getPlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return empty list - load real data from API instead
    return [];
  }

  Future<PlanModel> createPlan(Map<String, dynamic> planData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return PlanModel(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      name: planData['name'],
      price: planData['price'],
      dataLimitGB: planData['dataLimitGB'],
      validityDays: planData['validityDays'],
      speedMbps: planData['speedMbps'],
      isActive: true,
    );
  }

  Future<void> assignPlan(String userId, String planId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<TransactionModel>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return empty list - load real data from API instead
    return [];
  }

  Future<double> getWalletBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return 0.0 - load real data from API instead
    return 0.0;
  }

  Future<void> requestPayout(double amount, String method) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
