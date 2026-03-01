import 'dart:async';

class UpdateService {
  Future<Map<String, dynamic>?> checkUpdate() async {
    throw UnimplementedError();
  }

  Future<void> performUpdate(String url, {Function(int received, int total)? onProgress}) async {
    throw UnimplementedError();
  }
}
