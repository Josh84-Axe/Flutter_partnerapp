import '../models/plan_model.dart';
import '../models/transaction_model.dart';

class PaymentService {
  Future<List<PlanModel>> getPlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      PlanModel(
        id: 'plan_001',
        name: 'Basic',
        price: 9.99,
        dataLimitGB: 10,
        validityDays: 30,
        speedMbps: 10,
        isActive: true,
      ),
      PlanModel(
        id: 'plan_002',
        name: 'Standard',
        price: 19.99,
        dataLimitGB: 50,
        validityDays: 30,
        speedMbps: 50,
        isActive: true,
      ),
      PlanModel(
        id: 'plan_003',
        name: 'Premium',
        price: 39.99,
        dataLimitGB: 200,
        validityDays: 30,
        speedMbps: 100,
        isActive: true,
      ),
    ];
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
    
    return [
      TransactionModel(
        id: 'txn_001',
        type: 'revenue',
        amount: 149.95,
        status: 'completed',
        description: 'Plan subscription - Alice Johnson',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TransactionModel(
        id: 'txn_002',
        type: 'revenue',
        amount: 89.97,
        status: 'completed',
        description: 'Plan subscription - Bob Smith',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      TransactionModel(
        id: 'txn_003',
        type: 'payout',
        amount: -500.00,
        status: 'pending',
        description: 'Withdrawal request',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: 'txn_004',
        type: 'revenue',
        amount: 199.96,
        status: 'completed',
        description: 'Plan subscription - Carol White',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<double> getWalletBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 2847.53;
  }

  Future<void> requestPayout(double amount, String method) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
