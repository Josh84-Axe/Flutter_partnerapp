class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final List<String>? permissions;
  final List<String>? assignedRouters;
  final String? country;
  final String? address;
  final String? city;
  final int? numberOfRouters;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.isActive,
    required this.createdAt,
    this.permissions,
    this.assignedRouters,
    this.country,
    this.address,
    this.city,
    this.numberOfRouters,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both customer API response and legacy format
    if (json.containsKey('customer')) {
      // Customer API response format
      return UserModel(
        id: json['customer']?.toString() ?? json['id']?.toString() ?? '',
        name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
        email: json['email'] ?? '',
        role: 'user', // Use lowercase 'user' to match UsersScreen filter
        phone: json['phone'],
        isActive: !(json['blocked'] ?? false),
        createdAt: json['date_added'] != null 
            ? DateTime.tryParse(json['date_added']) ?? DateTime.now()
            : DateTime.now(),
        permissions: null,
        assignedRouters: null,
        country: json['country_name'],
        address: null,
        city: null,
        numberOfRouters: null,
      );
    } else {
      // Legacy format
      return UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'User',
        phone: json['phone'],
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        permissions: json['permissions'] != null 
            ? List<String>.from(json['permissions']) 
            : null,
        assignedRouters: json['assignedRouters'] != null
            ? List<String>.from(json['assignedRouters'])
            : null,
        country: json['country'],
        address: json['address'],
        city: json['city'],
        numberOfRouters: json['numberOfRouters'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'permissions': permissions,
      'assignedRouters': assignedRouters,
      'country': country,
      'address': address,
      'city': city,
      'numberOfRouters': numberOfRouters,
    };
  }
}
