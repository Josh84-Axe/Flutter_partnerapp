import 'package:easy_localization/easy_localization.dart';

class SimpleRouter {
  final String id;
  final String dnsName;
  
  SimpleRouter({required this.id, required this.dnsName});
}

class HotspotProfileModel {
  final String id;
  final String slug; // URL-friendly identifier for API endpoints
  final String name;
  final int downloadSpeedMbps;
  final int uploadSpeedMbps;
  final String idleTimeout;
  final List<String> routerIds;
  final List<SimpleRouter> routerDetails;
  final bool isPromo;
  final bool isActive;

  HotspotProfileModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.downloadSpeedMbps,
    required this.uploadSpeedMbps,
    required this.idleTimeout,
    this.routerIds = const [],
    this.routerDetails = const [],
    this.isPromo = false,
    this.isActive = true,
  });

  String get speedDescription => '$downloadSpeedMbps Mbps / $uploadSpeedMbps Mbps • ${'idle_timeout'.tr()} $idleTimeout';

  factory HotspotProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse rate_limit_value (e.g., "5m/5m" or "2m/2m")
    final rateLimitValue = json['rate_limit_value']?.toString() ?? '0m/0m';
    final speeds = rateLimitValue.split('/');
    final downloadSpeed = speeds.isNotEmpty ? _parseSpeed(speeds[0]) : 0;
    final uploadSpeed = speeds.length > 1 ? _parseSpeed(speeds[1]) : 0;
    
    // Parse routers
    List<String> routers = [];
    List<SimpleRouter> routerDetailsList = [];
    
    if (json['routers_detail'] != null && json['routers_detail'] is List) {
      final details = json['routers_detail'] as List;
      
      routers = details
          .map((r) => r['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
          
      routerDetailsList = details.map((r) {
        // Try to find dns_name, fallback to slug, then name
        final dns = r['dns_name']?.toString() ?? r['slug']?.toString() ?? r['name']?.toString() ?? '';
        return SimpleRouter(
          id: r['id']?.toString() ?? '',
          dnsName: dns,
        );
      }).toList();
    }

    return HotspotProfileModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      downloadSpeedMbps: downloadSpeed,
      uploadSpeedMbps: uploadSpeed,
      idleTimeout: json['idle_timeout_value']?.toString() ?? json['idle_timeout']?.toString() ?? '0m',
      routerIds: routers,
      routerDetails: routerDetailsList,
      isPromo: json['is_for_promo'] ?? false,
      isActive: json['is_active'] ?? true,
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
      'rate_limit_value': '$downloadSpeedMbps/$uploadSpeedMbps', // Approximate reconstruction
      'idle_timeout_value': idleTimeout,
      'routers': routerIds,
      'is_for_promo': isPromo,
      'is_active': isActive,
    };
  }
}
