// Helper to parse double from string or num
double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

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
      monthlyFee: parseDouble(plan?['price_info']?['price'] ?? plan?['price'] ?? json['monthlyFee']),
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
  final String? priceDisplay;
  final List<String> features;
  final String? currency;
  final bool isPopular;
  final String duration;
  final String? countryName;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.priceDisplay,
    required this.features,
    this.currency,
    this.isPopular = false,
    this.duration = 'monthly',
    this.countryName,
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

    // Parse price info
    final priceInfo = json['price_info'] as Map<String, dynamic>?;
    final double price = parseDouble(priceInfo?['price'] ?? json['price']);
    final String? priceDisplay = priceInfo?['price_display']?.toString() ?? json['price_display']?.toString();
    final String? countryName = priceInfo?['country_name']?.toString();

    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Plan',
      description: json['description']?.toString() ?? '',
      price: price,
      priceDisplay: priceDisplay,
      features: parsedFeatures,
      isPopular: json['is_popular'] == true || json['isPopular'] == true,
      currency: json['currency']?.toString() ?? json['currency_code']?.toString(),
      duration: json['duration']?.toString() ?? 'monthly',
      countryName: countryName,
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
