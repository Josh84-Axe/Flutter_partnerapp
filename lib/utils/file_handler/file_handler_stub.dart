import 'dart:typed_data';

/// Abstract class for handling file operations
class FileHandler {
  /// Save and launch a file
  static Future<void> saveAndLaunchFile(Uint8List bytes, String fileName) {
    throw UnsupportedError('Cannot create a file handler without dart:html or dart:io');
  }
}
