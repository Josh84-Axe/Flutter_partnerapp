class SubscriptionModel {
  final String id;
  final String tier;
  final DateTime renewalDate;
  final bool isActive;
  final double monthlyFee;
  final Map<String, dynamic> features;

  SubscriptionModel({
    required this.id,
    required this.tier,
    required this.renewalDate,
    required this.isActive,
    required this.monthlyFee,
    required this.features,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      tier: json['tier'],
      renewalDate: DateTime.parse(json['renewalDate']),
      isActive: json['isActive'] ?? true,
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
      features: json['features'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tier': tier,
      'renewalDate': renewalDate.toIso8601String(),
      'isActive': isActive,
      'monthlyFee': monthlyFee,
      'features': features,
    };
  }
}
