class PlanRouter {
  final int id;
  final String name;
  final String dnsName;

  PlanRouter({
    required this.id, 
    required this.name,
    required this.dnsName,
  });

  factory PlanRouter.fromJson(Map<String, dynamic> json) {
    return PlanRouter(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      dnsName: json['dns_name'] ?? '',
    );
  }
}

class PlanModel {
  final int id;
  final String slug;
  final String name;
  final String price;
  final String priceDisplay;
  final int? dataLimit;
  final int validity;
  final String formattedValidity;
  final String validityValue;
  final bool isActive;
  final int sharedUsers;
  final String sharedUsersLabel;
  final String? description;
  final String? profileName;
  final int? profileId;
  final List<PlanRouter> routers;

  // Computed property for backward compatibility or convenience
  double get priceValue => double.tryParse(price) ?? 0.0;
  int get validityDays => validityValue.contains('d') ? int.tryParse(validityValue.replaceAll('d', '')) ?? 0 : 0;

  PlanModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.price,
    required this.priceDisplay,
    this.dataLimit,
    required this.validity,
    required this.formattedValidity,
    required this.validityValue,
    required this.isActive,
    required this.sharedUsers,
    required this.sharedUsersLabel,
    this.description,
    this.profileName,
    this.profileId,
    this.routers = const [],
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    var routersList = <PlanRouter>[];
    if (json['routers'] != null && json['routers'] is List) {
      routersList = (json['routers'] as List)
          .map((r) => PlanRouter.fromJson(r))
          .toList();
    }

    String rawPrice = json['price']?.toString() ?? '0';
    // Remove .00 or .0 decimals if it's a whole number
    if (rawPrice.endsWith('.00')) {
      rawPrice = rawPrice.substring(0, rawPrice.length - 3);
    } else if (rawPrice.endsWith('.0')) {
      rawPrice = rawPrice.substring(0, rawPrice.length - 2);
    }

    return PlanModel(
      id: json['id'],
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      price: rawPrice,
      priceDisplay: json['price_display'] ?? '',
      dataLimit: json['data_limit'],
      validity: json['validity'] ?? 0,
      formattedValidity: json['formatted_validity'] ?? '',
      validityValue: json['validity_value'] ?? '',
      isActive: json['is_active'] ?? true,
      sharedUsers: json['shared_users'] ?? 1,
      sharedUsersLabel: json['shared_users_label'] ?? '',
      description: json['description'],
      profileName: json['profile_name'],
      profileId: json['profile'],
      routers: routersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'price': price,
      'price_display': priceDisplay,
      'data_limit': dataLimit,
      'validity': validity,
      'formatted_validity': formattedValidity,
      'validity_value': validityValue,
      'is_active': isActive,
      'shared_users': sharedUsers,
      'shared_users_label': sharedUsersLabel,
      'description': description,
      'profile_name': profileName,
      'profile': profileId,
      'routers': routers.map((r) => {'id': r.id, 'name': r.name, 'dns_name': r.dnsName}).toList(),
    };
  }
}
