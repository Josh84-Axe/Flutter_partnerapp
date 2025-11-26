import 'package:easy_localization/easy_localization.dart';

class HotspotProfileModel {
  final String id;
  final String name;
  final int downloadSpeedMbps;
  final int uploadSpeedMbps;
  final String idleTimeout;

  HotspotProfileModel({
    required this.id,
    required this.name,
    required this.downloadSpeedMbps,
    required this.uploadSpeedMbps,
    required this.idleTimeout,
  });

  String get speedDescription => '$downloadSpeedMbps Mbps / $uploadSpeedMbps Mbps • ${'idle_timeout'.tr()} $idleTimeout';

  factory HotspotProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse rate_limit_value (e.g., "5m/5m" or "2m/2m")
    final rateLimitValue = json['rate_limit_value']?.toString() ?? '0m/0m';
    final speeds = rateLimitValue.split('/');
    final downloadSpeed = speeds.isNotEmpty ? _parseSpeed(speeds[0]) : 0;
    final uploadSpeed = speeds.length > 1 ? _parseSpeed(speeds[1]) : 0;
    
    return HotspotProfileModel(
      id: json['id']?.toString() ?? json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      downloadSpeedMbps: downloadSpeed,
      uploadSpeedMbps: uploadSpeed,
      idleTimeout: json['idle_timeout_value']?.toString() ?? json['idle_timeout']?.toString() ?? '0m',
    );
  }

  /// Parse speed string like "5m" to integer (assuming 'm' means Mbps)
  static int _parseSpeed(String speedStr) {
    final cleaned = speedStr.trim().toLowerCase().replaceAll('m', '').replaceAll('bps', '');
    return int.tryParse(cleaned) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'downloadSpeedMbps': downloadSpeedMbps,
      'uploadSpeedMbps': uploadSpeedMbps,
      'idleTimeout': idleTimeout,
    };
  }
}
