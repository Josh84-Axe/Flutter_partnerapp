class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String status;
  final String description;
  final DateTime createdAt;
  final String? paymentMethod;
  final String? gateway;
  final String? workerId;
  final String? accountId;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.paymentMethod,
    this.gateway,
    this.workerId,
    this.accountId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      paymentMethod: json['paymentMethod'],
      gateway: json['gateway'],
      workerId: json['workerId'],
      accountId: json['accountId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'gateway': gateway,
      'workerId': workerId,
      'accountId': accountId,
    };
  }
}
