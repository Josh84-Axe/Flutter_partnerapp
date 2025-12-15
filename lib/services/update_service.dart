import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/update_config.dart';

class UpdateService {
  final Dio _dio = Dio();

  /// Checks if a new update is available.
  /// Returns a Map with update details if available, or null if no update.
  Future<Map<String, dynamic>?> checkUpdate() async {
    if (kIsWeb) return null; // Updates not applicable for web

    try {
      final response = await _dio.get(UpdateConfig.versionCheckUrl);

      if (response.statusCode == 200) {
        final data = response.data is String ? _parseJson(response.data) : response.data;
        final latestVersion = data['latestVersion'] as String?;
        final downloadUrl = data['downloadUrl'] as String?;

        if (latestVersion != null && downloadUrl != null) {
          final packageInfo = await PackageInfo.fromPlatform();
          final currentVersion = packageInfo.version;

          if (_isNewerVersion(latestVersion, currentVersion)) {
            return {
              'latestVersion': latestVersion,
              'currentVersion': currentVersion,
              'downloadUrl': downloadUrl,
              'releaseNotes': data['releaseNotes'] ?? 'New version available.',
              'forceUpdate': data['forceUpdate'] ?? false,
            };
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UpdateService] Error checking for updates: $e');
      }
    }
    return null;
  }
  
  Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('Error parsing JSON: $e');
      return {};
    }
  }

  /// Triggers the OTA update process.
  Future<void> performUpdate(String url) async {
    try {
       await RUpgrade.upgrade(
         url,
         fileName: 'partner_app_update.apk',
         notificationStyle: NotificationStyle.speechAndPlanTime,
       );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UpdateService] Error performing update: $e');
      }
      rethrow;
    }
  }

  /// Compares two version strings (e.g., "1.0.1" vs "1.0.0").
  bool _isNewerVersion(String latest, String current) {
    List<int> latestParts = latest.split('.').map(int.parse).toList();
    List<int> currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
        // If current doesn't have this part (e.g. 1.0 vs 1.0.1), assume 0
        int currentPart = i < currentParts.length ? currentParts[i] : 0;
        
        if (latestParts[i] > currentPart) return true;
        if (latestParts[i] < currentPart) return false;
    }
    return false; // Versions are equal
  }
}
