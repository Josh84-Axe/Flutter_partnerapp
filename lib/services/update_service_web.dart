import 'dart:async';

class UpdateService {
  // Disabling update check in web due to CORS issues with raw.githubusercontent.com
  Future<Map<String, dynamic>?> checkUpdate() async {
    return null;
  }

  Future<void> performUpdate(String url, {Function(int received, int total)? onProgress}) async {
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
