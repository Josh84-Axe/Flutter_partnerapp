class RouterModel {
  final String id;
  final String name;
  final String slug;
  final String? ipAddress;
  final String status;
  final int connectedUsers;
  final double dataUsageGB;
  final int uptimeHours;
  final DateTime? lastSeen;

  RouterModel({
    required this.id,
    required this.name,
    required this.slug,
    this.ipAddress,
    this.status = 'unknown',
    this.connectedUsers = 0,
    this.dataUsageGB = 0.0,
    this.uptimeHours = 0,
    this.lastSeen,
  });

  factory RouterModel.fromJson(Map<String, dynamic> json) {
    return RouterModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      ipAddress: json['ip_address'],
      // Prefer explicit connectivity status from API if present
      status: (json['is_online'] == true || json['is_connected'] == true || json['status'] == 'online')
          ? 'online'
          : (json['status'] == 'offline' || json['is_connected'] == false || json['is_online'] == false
              ? 'offline'
              : ((json['is_active'] == true) ? 'online' : 'offline')),
      connectedUsers: json['connected_users'] ?? 0,
      dataUsageGB: (json['data_usage_gb'] as num?)?.toDouble() ?? 0.0,
      uptimeHours: json['uptime_hours'] ?? 0,
      lastSeen: json['last_seen'] != null ? DateTime.tryParse(json['last_seen']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'ip_address': ipAddress,
      'status': status,
      'connected_users': connectedUsers,
      'data_usage_gb': dataUsageGB,
      'uptime_hours': uptimeHours,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }
}
