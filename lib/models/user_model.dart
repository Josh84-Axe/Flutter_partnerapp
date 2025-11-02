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
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
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
