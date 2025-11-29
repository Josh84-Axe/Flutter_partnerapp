class PlanModel {
  final int id; // Changed from String to int based on API
  final String slug;
  final String name;
  final String price; // API returns string "10.00"
  final String priceDisplay; // API returns "10 GHS"
  final int? dataLimit; // Nullable for unlimited
  final int validity; // This seems to be an ID or raw value
  final String formattedValidity; // "30 Minutes", "1 Day"
  final String validityValue; // "30m", "1d"
  final bool isActive;
  final int sharedUsers; // Renamed from deviceAllowed
  final String sharedUsersLabel; // "1 device"
  final String? description;
  final String? profileName;
  final int? profileId;

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
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0.00',
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
    };
  }
}
