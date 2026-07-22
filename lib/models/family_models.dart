class FamilyDevice {
  final int id;
  final int groupId;
  final String deviceName;
  final String macAddress;
  final bool isPaused;
  final DateTime? pauseUntil;
  final int? activePolicyId;
  final String? activePolicyName;

  FamilyDevice({
    required this.id,
    required this.groupId,
    required this.deviceName,
    required this.macAddress,
    required this.isPaused,
    this.pauseUntil,
    this.activePolicyId,
    this.activePolicyName,
  });

  factory FamilyDevice.fromJson(Map<String, dynamic> json) {
    return FamilyDevice(
      id: json['id'],
      groupId: json['group_id'] ?? 0,
      deviceName: json['device_name'] ?? 'Device',
      macAddress: json['mac_address'] ?? '',
      isPaused: json['is_paused'] ?? false,
      pauseUntil: json['pause_until'] != null 
          ? DateTime.tryParse(json['pause_until']) 
          : null,
      activePolicyId: json['active_policy_id'],
      activePolicyName: json['active_policy_name'],
    );
  }
}

class PolicySchedule {
  final int id;
  final int deviceId;
  final String name;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int policyId;
  final bool isActive;

  PolicySchedule({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.policyId,
    required this.isActive,
  });

  factory PolicySchedule.fromJson(Map<String, dynamic> json) {
    return PolicySchedule(
      id: json['id'],
      deviceId: json['device_id'],
      name: json['name'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time'] ?? '00:00',
      endTime: json['end_time'] ?? '00:00',
      policyId: json['policy_id'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class ContentPolicy {
  final int id;
  final String name;
  final String description;
  final Map<String, dynamic> categories;

  ContentPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
  });

  factory ContentPolicy.fromJson(Map<String, dynamic> json) {
    return ContentPolicy(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categories: Map<String, dynamic>.from(json['categories'] ?? {}),
    );
  }
}

class UnclaimedDevice {
  final String macAddress;
  final String formattedMac;
  final String ipAddress;
  final String vendor;
  final DateTime lastSeen;

  UnclaimedDevice({
    required this.macAddress,
    required this.formattedMac,
    required this.ipAddress,
    required this.vendor,
    required this.lastSeen,
  });

  factory UnclaimedDevice.fromJson(Map<String, dynamic> json) {
    return UnclaimedDevice(
      macAddress: json['mac_address'] ?? '',
      formattedMac: json['formatted_mac'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      vendor: json['vendor'] ?? 'Unknown Device',
      lastSeen: DateTime.tryParse(json['last_seen'] ?? '') ?? DateTime.now(),
    );
  }
}
