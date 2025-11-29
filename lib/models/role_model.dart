class RoleModel {
  final String id;
  final String name;
  final String slug;
  final Map<String, bool> permissions;

  RoleModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? json['id']?.toString() ?? '', // Fallback to ID if slug missing
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'permissions': permissions,
    };
  }
}
