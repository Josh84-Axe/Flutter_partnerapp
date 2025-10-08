class RouterModel {
  final String id;
  final String name;
  final String macAddress;
  final String status;
  final int connectedUsers;
  final double dataUsageGB;
  final int uptimeHours;
  final DateTime lastSeen;

  RouterModel({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.status,
    required this.connectedUsers,
    required this.dataUsageGB,
    required this.uptimeHours,
    required this.lastSeen,
  });

  factory RouterModel.fromJson(Map<String, dynamic> json) {
    return RouterModel(
      id: json['id'],
      name: json['name'],
      macAddress: json['macAddress'],
      status: json['status'],
      connectedUsers: json['connectedUsers'],
      dataUsageGB: (json['dataUsageGB'] as num).toDouble(),
      uptimeHours: json['uptimeHours'],
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'macAddress': macAddress,
      'status': status,
      'connectedUsers': connectedUsers,
      'dataUsageGB': dataUsageGB,
      'uptimeHours': uptimeHours,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }
}
