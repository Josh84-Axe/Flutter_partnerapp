class VoucherModel {
  final String id;
  final String code;
  final String planId;
  final String planName;
  final String status; // Derived from is_used/is_expired
  final bool isUsed;
  final bool isExpired;
  final bool isAssigned;
  final String? usedBy;
  final DateTime createdAt;
  final DateTime? usedAt;
  final DateTime? assignedAt;

  VoucherModel({
    required this.id,
    required this.code,
    required this.planId,
    required this.planName,
    required this.status,
    this.isUsed = false,
    this.isExpired = false,
    this.isAssigned = false,
    this.usedBy,
    required this.createdAt,
    this.usedAt,
    this.assignedAt,
  });

  bool get isActive => !isUsed && !isExpired;

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    final bool isUsed = json['is_used'] ?? false;
    final bool isExpired = json['is_expired'] ?? false;
    
    String status = 'active';
    if (isUsed) {
      status = 'used';
    } else if (isExpired) status = 'expired';

    return VoucherModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      planId: json['plan']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? 'Unknown Plan',
      status: status,
      isUsed: isUsed,
      isExpired: isExpired,
      isAssigned: json['is_assigned'] ?? false,
      usedBy: json['used_by']?.toString(),
      createdAt: json['generated_at'] != null 
          ? DateTime.parse(json['generated_at']) 
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      usedAt: json['used_at'] != null 
          ? DateTime.parse(json['used_at']) 
          : null,
      assignedAt: json['is_assigned_at'] != null
          ? DateTime.parse(json['is_assigned_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'plan': planId,
      'plan_name': planName,
      'status': status,
      'is_used': isUsed,
      'is_expired': isExpired,
      'is_assigned': isAssigned,
      'used_by': usedBy,
      'generated_at': createdAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'is_assigned_at': assignedAt?.toIso8601String(),
    };
  }
}
