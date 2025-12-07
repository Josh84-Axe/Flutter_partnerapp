import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart';

class FileHandler {
  static Future<void> saveAndLaunchFile(Uint8List bytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(bytes);
      
      if (kDebugMode) print('✅ File saved to: $path');
      
      final result = await OpenFile.open(path);
      if (kDebugMode) print('📂 Open file result: ${result.message}');
    } catch (e) {
      if (kDebugMode) print('❌ Error saving/opening file: $e');
      rethrow;
    }
  }
}
