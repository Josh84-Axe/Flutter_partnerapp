âclass WorkerModel {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String? roleSlug;
  final String? roleName;
  final List<String>? permissions;
  final List<String>? assignedRouters;
  final bool isActive;
  final DateTime createdAt;

  WorkerModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.roleSlug,
    this.roleName,
    this.permissions,
    this.assignedRouters,
    required this.isActive,
    required this.createdAt,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();

    return WorkerModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      fullName: fullName.isNotEmpty ? fullName : (json['name'] ?? ''),
      email: json['email'] ?? '',
      roleSlug: json['role']?.toString(),
      roleName: json['role_name']?.toString(),
      permissions: (json['permissions'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      assignedRouters: (json['assigned_routers'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'role': roleSlug,
      'role_name': roleName,
      'permissions': permissions,
      'assigned_routers': assignedRouters,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
Ö Öþ
þè èƒ*cascade08
ƒ„ „›
›– – 
 ¡ ¡¢
¢£ £¬
¬° °±
±µ µ¶*cascade08
¶· ·¸*cascade08
¸Ê ÊË*cascade08
Ë»	 »	³
*cascade08
³
Ò Òþ
þâ "(cca2f84a38c6f96ed1ed663b94e21ada205472c02efile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/models/worker_model.dart:Hfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp