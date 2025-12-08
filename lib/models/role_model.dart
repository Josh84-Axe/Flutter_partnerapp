class RoleModel {
  final String id;
  final String name;
  final String slug;
  final Map<String, bool> permissions;
  final String? description;
  final int? memberCount;

  RoleModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.permissions,
    this.description,
    this.memberCount,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? json['id']?.toString() ?? '', // Fallback to ID if slug missing
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
      description: json['description'],
      memberCount: json['member_count'] ?? json['users_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'permissions': permissions,
      'description': description,
      'member_count': memberCount,
    };
  }
}
