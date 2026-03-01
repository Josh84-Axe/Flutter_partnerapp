import 'dart:async';
import 'package:flutter/foundation.dart';

class UpdateService {
  Future<Map<String, dynamic>?> checkUpdate() async {
    if (kDebugMode) print('🌐 [UpdateService] Web environment detected. Skipping update check.');
    return null;
  }

  Future<void> performUpdate(String url, {Function(int received, int total)? onProgress}) async {
    if (kDebugMode) print('🌐 [UpdateService] Web update handled by browser refresh.');
    return;
  }
}
