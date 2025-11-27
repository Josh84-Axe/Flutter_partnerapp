class SubscriptionModel {
  final String id;
  final String tier;
  final DateTime renewalDate;
  final bool isActive;
  final double monthlyFee;
  final List<String> features;

  SubscriptionModel({
    required this.id,
    required this.tier,
    required this.renewalDate,
    required this.isActive,
    required this.monthlyFee,
    required this.features,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    // Handle API response structure where plan details are nested
    final plan = json['plan'] as Map<String, dynamic>?;
    
    // Parse features list
    List<String> parsedFeatures = [];
    final featuresData = plan?['features'] ?? json['features'];
    if (featuresData is List) {
      parsedFeatures = featuresData.map((f) {
        if (f is Map) {
          return f['name']?.toString() ?? '';
        } else if (f is String) {
          return f;
        }
        return '';
      }).where((s) => s.isNotEmpty).cast<String>().toList();
    }

    return SubscriptionModel(
      id: plan?['id']?.toString() ?? json['id']?.toString() ?? '',
      tier: plan?['name']?.toString() ?? json['tier']?.toString() ?? 'Unknown',
      renewalDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : (json['renewalDate'] != null ? DateTime.parse(json['renewalDate']) : DateTime.now()),
      isActive: json['active'] ?? json['isActive'] ?? false,
      monthlyFee: (plan?['price'] as num?)?.toDouble() ?? (json['monthlyFee'] as num?)?.toDouble() ?? 0.0,
      features: parsedFeatures,
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

/// Model for available subscription plans
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    this.isPopular = false,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    // Parse features list
    List<String> parsedFeatures = [];
    if (json['features'] is List) {
      parsedFeatures = (json['features'] as List).map((f) {
        if (f is Map) {
          return f['name']?.toString() ?? '';
        } else if (f is String) {
          return f;
        }
        return '';
      }).where((s) => s.isNotEmpty).cast<String>().toList();
    }

    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Plan',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      features: parsedFeatures,
      isPopular: json['is_popular'] == true || json['isPopular'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'features': features,
      'isPopular': isPopular,
    };
  }
}
