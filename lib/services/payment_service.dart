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
      id: DateTime.now().millisecondsSinceEpoch,
      slug: 'mock-plan',
      name: planData['name'],
      price: planData['price'].toString(),
      priceDisplay: '${planData['price']} GHS',
      dataLimit: planData['dataLimitGB'],
      validity: planData['validityDays'] ?? 30,
      formattedValidity: '${planData['validityDays']} Days',
      validityValue: '${planData['validityDays']}d',
      isActive: true,
      sharedUsers: 1,
      sharedUsersLabel: '1 Device',
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
