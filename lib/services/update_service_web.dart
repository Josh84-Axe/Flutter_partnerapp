import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/update_config.dart';

class UpdateService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      if (kDebugMode) print('🌐 [UpdateService] Skipping GitHub check for web stability...');
      // CORS blocking makes this unreliable in web without proxy
      /*
      final response = await _dio.get(
        UpdateConfig.versionCheckUrl,
        options: Options(
          headers: {'Cache-Control': 'no-cache'},
        ),
      );
      */
      return null; 

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        final latestVersion = data['latestVersion'] as String?;
        
        if (latestVersion != null) {
          final packageInfo = await PackageInfo.fromPlatform();
          final currentVersion = packageInfo.version;

          if (kDebugMode) print('🌐 [UpdateService] Current: $currentVersion, Latest: $latestVersion');

          if (_isNewerVersion(latestVersion, currentVersion)) {
            return {
              'latestVersion': latestVersion,
              'currentVersion': currentVersion,
              'downloadUrl': data['downloadUrl'] ?? '',
              'releaseNotes': data['releaseNotes'] ?? 'A new version is available.',
              'forceUpdate': data['forceUpdate'] ?? false,
            };
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ [UpdateService] Error checking web updates: $e');
    }
    return null;
  }

  Future<void> performUpdate(String url, {Function(int received, int total)? onProgress}) async {
    if (kDebugMode) print('🌐 [UpdateService] Web update: Reloading page to fetch new content.');
    // In web, we just need to reload. The service worker logic in index.html will handle the rest.
    // However, if we are calling this from Dart, we can trigger a JS refresh.
    // For now, let's assume the user saw the dialog and chose to update.
    return;
  }

  bool _isNewerVersion(String latest, String current) {
    if (latest == current) return false;
    
    List<int> latestParts = latest.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    List<int> currentParts = current.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      int currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (latestParts[i] > currentPart) return true;
      if (latestParts[i] < currentPart) return false;
    }
    
    // Check build number if version parts are equal
    if (latest.contains('+') && current.contains('+')) {
      int latestBuild = int.tryParse(latest.split('+').last) ?? 0;
      int currentBuild = int.tryParse(current.split('+').last) ?? 0;
      return latestBuild > currentBuild;
    }

    return false;
  }
}
