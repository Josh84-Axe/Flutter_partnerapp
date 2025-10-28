class RoleModel {
  final String id;
  final String name;
  final Map<String, bool> permissions;

  RoleModel({
    required this.id,
    required this.name,
    required this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permissions': permissions,
    };
  }
}
