import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class FileHandler {
  static Future<void> saveAndLaunchFile(Uint8List bytes, String fileName) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      
      if (kDebugMode) print('✅ File download triggered for: $fileName');
    } catch (e) {
      if (kDebugMode) print('❌ Error downloading file: $e');
      rethrow;
    }
  }
}
