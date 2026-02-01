class VoucherModel {
  final String id;
  final String code;
  final String planId;
  final String planName;
  final String status; // 'active', 'used', 'expired'
  final String? usedBy;
  final DateTime createdAt;
  final DateTime? usedAt;

  VoucherModel({
    required this.id,
    required this.code,
    required this.planId,
    required this.planName,
    required this.status,
    this.usedBy,
    required this.createdAt,
    this.usedAt,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isUsed => status.toLowerCase() == 'used';

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      planId: json['plan']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? 'Unknown Plan',
      status: json['status']?.toString() ?? 'unknown',
      usedBy: json['used_by']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      usedAt: json['used_at'] != null 
          ? DateTime.parse(json['used_at']) 
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
      'used_by': usedBy,
      'created_at': createdAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
    };
  }
}
