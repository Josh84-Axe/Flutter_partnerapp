import 'package:flutter/material.dart';

class FamilyDevice {
  final int id;
  final int groupId;
  final String deviceName;
  final String macAddress;
  final bool isPaused;
  final bool isOnline;
  final DateTime? pauseUntil;
  final int? activePolicyId;
  final String? activePolicyName;
  final String vendor;
  final String deviceType;
  final String deviceTypeLabel;
  final String iconName;
  final String fingerprintSummary;
  final String hostname;

  FamilyDevice({
    required this.id,
    required this.groupId,
    required this.deviceName,
    required this.macAddress,
    required this.isPaused,
    this.isOnline = false,
    this.pauseUntil,
    this.activePolicyId,
    this.activePolicyName,
    this.vendor = 'Unknown Brand',
    this.deviceType = 'smartphone',
    this.deviceTypeLabel = 'Connected Device',
    this.iconName = 'devices',
    this.fingerprintSummary = '',
    this.hostname = '',
  });

  factory FamilyDevice.fromJson(Map<String, dynamic> json) {
    return FamilyDevice(
      id: json['id'],
      groupId: json['group_id'] ?? 0,
      deviceName: json['device_name'] ?? 'Device',
      macAddress: json['mac_address'] ?? '',
      isPaused: json['is_paused'] ?? false,
      isOnline: json['is_online'] ?? false,
      pauseUntil: json['pause_until'] != null 
          ? DateTime.tryParse(json['pause_until']) 
          : null,
      activePolicyId: json['active_policy_id'],
      activePolicyName: json['active_policy_name'],
      vendor: json['vendor'] ?? 'Unknown Brand',
      deviceType: json['device_type'] ?? 'smartphone',
      deviceTypeLabel: json['device_type_label'] ?? 'Connected Device',
      iconName: json['icon_name'] ?? 'devices',
      fingerprintSummary: json['fingerprint_summary'] ?? '',
      hostname: json['hostname'] ?? '',
    );
  }

  FamilyDevice copyWith({
    int? id,
    int? groupId,
    String? deviceName,
    String? macAddress,
    bool? isPaused,
    bool? isOnline,
    DateTime? pauseUntil,
    int? activePolicyId,
    String? activePolicyName,
    String? vendor,
    String? deviceType,
    String? deviceTypeLabel,
    String? iconName,
    String? fingerprintSummary,
    String? hostname,
  }) {
    return FamilyDevice(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      deviceName: deviceName ?? this.deviceName,
      macAddress: macAddress ?? this.macAddress,
      isPaused: isPaused ?? this.isPaused,
      isOnline: isOnline ?? this.isOnline,
      pauseUntil: pauseUntil ?? this.pauseUntil,
      activePolicyId: activePolicyId ?? this.activePolicyId,
      activePolicyName: activePolicyName ?? this.activePolicyName,
      vendor: vendor ?? this.vendor,
      deviceType: deviceType ?? this.deviceType,
      deviceTypeLabel: deviceTypeLabel ?? this.deviceTypeLabel,
      iconName: iconName ?? this.iconName,
      fingerprintSummary: fingerprintSummary ?? this.fingerprintSummary,
      hostname: hostname ?? this.hostname,
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
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? 0,
      name: json['name'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time'] ?? '00:00',
      endTime: json['end_time'] ?? '00:00',
      policyId: json['policy_id'] ?? 0,
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
  final String deviceType;
  final String deviceTypeLabel;
  final String iconName;
  final String fingerprintSummary;
  final String hostname;
  final DateTime lastSeen;

  UnclaimedDevice({
    required this.macAddress,
    required this.formattedMac,
    required this.ipAddress,
    required this.vendor,
    this.deviceType = 'smartphone',
    this.deviceTypeLabel = 'Connected Device',
    this.iconName = 'devices',
    this.fingerprintSummary = '',
    this.hostname = '',
    required this.lastSeen,
  });

  factory UnclaimedDevice.fromJson(Map<String, dynamic> json) {
    return UnclaimedDevice(
      macAddress: json['mac_address'] ?? '',
      formattedMac: json['formatted_mac'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      vendor: json['vendor'] ?? 'Unknown Brand',
      deviceType: json['device_type'] ?? 'smartphone',
      deviceTypeLabel: json['device_type_label'] ?? 'Connected Device',
      iconName: json['icon_name'] ?? 'devices',
      fingerprintSummary: json['fingerprint_summary'] ?? '',
      hostname: json['hostname'] ?? '',
      lastSeen: DateTime.tryParse(json['last_seen'] ?? '') ?? DateTime.now(),
    );
  }
}

class ScreenTimeRule {
  final String id;
  final String label;
  final String deviceName;
  final int deviceId;
  final int dailyLimitMinutes;
  final List<int> allowedDays;
  final TimeOfDay? accessStart;
  final TimeOfDay? accessEnd;
  bool isEnabled;

  ScreenTimeRule({
    required this.id,
    required this.label,
    required this.deviceName,
    required this.deviceId,
    required this.dailyLimitMinutes,
    required this.allowedDays,
    this.accessStart,
    this.accessEnd,
    this.isEnabled = true,
  });

  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return null;
  }

  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  factory ScreenTimeRule.fromJson(Map<String, dynamic> json) {
    return ScreenTimeRule(
      id: json['id']?.toString() ?? '',
      label: json['label'] ?? '',
      deviceName: json['device_name'] ?? '',
      deviceId: json['device_id'] ?? 0,
      dailyLimitMinutes: json['daily_limit_minutes'] ?? 0,
      allowedDays: (json['allowed_days'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      accessStart: _parseTime(json['access_start']),
      accessEnd: _parseTime(json['access_end']),
      isEnabled: json['is_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'daily_limit_minutes': dailyLimitMinutes,
      'allowed_days': allowedDays,
      'access_start': _formatTime(accessStart),
      'access_end': _formatTime(accessEnd),
      'is_enabled': isEnabled,
    };
  }
}
