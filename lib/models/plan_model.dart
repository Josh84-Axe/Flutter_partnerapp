class PlanModel {
  final String id;
  final String name;
  final double price;
  final int dataLimitGB;
  final int validityDays;
  final int speedMbps;
  final bool isActive;
  final int deviceAllowed;
  final String userProfile;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.dataLimitGB,
    required this.validityDays,
    required this.speedMbps,
    required this.isActive,
    this.deviceAllowed = 1,
    this.userProfile = 'Basic',
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      dataLimitGB: json['dataLimitGB'],
      validityDays: json['validityDays'],
      speedMbps: json['speedMbps'],
      isActive: json['isActive'] ?? true,
      deviceAllowed: json['deviceAllowed'] ?? 1,
      userProfile: json['userProfile'] ?? 'Basic',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'dataLimitGB': dataLimitGB,
      'validityDays': validityDays,
      'speedMbps': speedMbps,
      'isActive': isActive,
      'deviceAllowed': deviceAllowed,
      'userProfile': userProfile,
    };
  }
}
