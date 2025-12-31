import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/update_config.dart';

class UpdateService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5), // Allow 5 minutes for slow downloads
    sendTimeout: const Duration(minutes: 5),
  ));

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

  /// Triggers the OTA update process: Download -> Install.
  Future<void> performUpdate(String url) async {
    try {
       // 1. Request permissions
       if (Platform.isAndroid) {
         final status = await Permission.requestInstallPackages.status;
         if (!status.isGranted) {
           final result = await Permission.requestInstallPackages.request();
           if (!result.isGranted) {
             throw Exception('Install permission denied.');
           }
         }
       }

       // 2. Prepare destination
       final dir = await getTemporaryDirectory();
       final fileName = 'update_${DateTime.now().millisecondsSinceEpoch}.apk';
       final filePath = '${dir.path}/$fileName';
       
       // Clean up old update files
       final dirFiles = dir.listSync();
       for (var file in dirFiles) {
         if (file.path.endsWith('.apk') && file.path.contains('update_')) {
           try {
             file.deleteSync();
           } catch (e) {
             print('⚠️ Could not delete old update file: $e');
           }
         }
       }

       if (kDebugMode) print('⬇️ [UpdateService] Downloading to: $filePath');

       // 3. Download APK
       // Use deleteOnError to ensure partial files aren't kept if connection drops
       await _dio.download(
         url, 
         filePath,
         deleteOnError: true,
         onReceiveProgress: (received, total) {
           if (kDebugMode && total != -1) {
             // Print progress every 10%
             final progress = ((received / total) * 100).toInt();
             if (progress % 10 == 0) {
                print('⬇️ [UpdateService] Progress: $progress%');
             }
           }
         },
       );
       
       if (kDebugMode) print('✅ [UpdateService] Download complete. Opening...');

       // 4. Open/Install APK
       final result = await OpenFile.open(filePath);
       
       if (result.type != ResultType.done) {
         throw Exception('Error opening APK: ${result.message}');
       }

    } catch (e) {
      if (kDebugMode) {
        print('❌ [UpdateService] Error performing update: $e');
      }
      rethrow;
    }
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
