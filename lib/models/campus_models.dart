class StudentProfile {
  final String studentId;
  final String fullName;
  final String department;
  final int dailyQuotaMb;
  final int dataConsumedMb;
  final int remainingDataMb;
  final DateTime quotaResetsAt;
  final String currentPolicy;
  final bool isFastpathActive;

  StudentProfile({
    required this.studentId,
    required this.fullName,
    required this.department,
    required this.dailyQuotaMb,
    required this.dataConsumedMb,
    required this.remainingDataMb,
    required this.quotaResetsAt,
    required this.currentPolicy,
    required this.isFastpathActive,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentId: json['student_id'] ?? '',
      fullName: json['full_name'] ?? '',
      department: json['department'] ?? '',
      dailyQuotaMb: json['daily_quota_mb'] ?? 0,
      dataConsumedMb: json['data_consumed_mb'] ?? 0,
      remainingDataMb: json['remaining_data_mb'] ?? 0,
      quotaResetsAt: json['quota_resets_at'] != null 
          ? DateTime.tryParse(json['quota_resets_at']) ?? DateTime.now()
          : DateTime.now(),
      currentPolicy: json['current_policy'] ?? 'DEFAULT',
      isFastpathActive: json['is_fastpath_active'] ?? false,
    );
  }

  double get quotaUsagePercentage =>
      dailyQuotaMb > 0 ? (dataConsumedMb / dailyQuotaMb).clamp(0.0, 1.0) : 0.0;
}

class CampusSchedule {
  final String name;
  final String startTime;
  final String endTime;
  final List<String> restrictedCategories;
  final List<String> prioritizedPortals;
  final bool isCurrentlyActive;

  CampusSchedule({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.restrictedCategories,
    required this.prioritizedPortals,
    required this.isCurrentlyActive,
  });

  factory CampusSchedule.fromJson(Map<String, dynamic> json) {
    return CampusSchedule(
      name: json['name'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      restrictedCategories: List<String>.from(json['restricted_categories'] ?? []),
      prioritizedPortals: List<String>.from(json['prioritized_portals'] ?? []),
      isCurrentlyActive: json['is_currently_active'] ?? false,
    );
  }
}
