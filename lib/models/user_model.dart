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
  
  // New fields for status tracking
  final bool? isBlocked;
  final bool? isConnected;
  final String? username;
  final String? lastConnection;
  final int? totalSessions;
  final String? acquisitionType;

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
    this.isBlocked,
    this.isConnected,
    this.username,
    this.lastConnection,
    this.totalSessions,
    this.acquisitionType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {bool? isConnected}) {
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
        isBlocked: json['blocked'],
        isConnected: isConnected,
        username: json['username'],
        lastConnection: null,
        totalSessions: null,
        acquisitionType: json['acquisition_type'],
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
        isBlocked: json['isBlocked'],
        isConnected: isConnected ?? json['isConnected'],
        username: json['username'],
        lastConnection: json['lastConnection'],
        totalSessions: json['totalSessions'],
        acquisitionType: json['acquisitionType'],
      );
    }
  }

  // Getters for name parts
  String get firstName => name.split(' ').first;
  String get lastName => name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '';

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    List<String>? permissions,
    List<String>? assignedRouters,
    String? country,
    String? address,
    String? city,
    int? numberOfRouters,
    bool? isBlocked,
    bool? isConnected,
    String? username,
    String? lastConnection,
    int? totalSessions,
    String? acquisitionType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      permissions: permissions ?? this.permissions,
      assignedRouters: assignedRouters ?? this.assignedRouters,
      country: country ?? this.country,
      address: address ?? this.address,
      city: city ?? this.city,
      numberOfRouters: numberOfRouters ?? this.numberOfRouters,
      isBlocked: isBlocked ?? this.isBlocked,
      isConnected: isConnected ?? this.isConnected,
      username: username ?? this.username,
      lastConnection: lastConnection ?? this.lastConnection,
      totalSessions: totalSessions ?? this.totalSessions,
      acquisitionType: acquisitionType ?? this.acquisitionType,
    );
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
      'isBlocked': isBlocked,
      'isConnected': isConnected,
      'username': username,
      'lastConnection': lastConnection,
      'totalSessions': totalSessions,
      'acquisitionType': acquisitionType,
    };
  }
}

