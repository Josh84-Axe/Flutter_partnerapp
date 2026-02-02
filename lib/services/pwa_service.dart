import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class PwaService {
  static final PwaService _instance = PwaService._internal();
  factory PwaService() => _instance;
  PwaService._internal();

  final _installableController = StreamController<bool>.broadcast();
  Stream<bool> get installableStream => _installableController.stream;

  bool _isInstallable = false;
  bool get isInstallable => _isInstallable;

  void init() {
    if (!kIsWeb) return;

    // Register callback for JS
    js.context['onAppInstallable'] = js.allowInterop(() {
      _isInstallable = true;
      _installableController.add(true);
      if (kDebugMode) print('🌐 [PwaService] App is installable');
    });

    // Check initial state
    _isInstallable = js.context.callMethod('isAppInstallable') ?? false;
    _installableController.add(_isInstallable);
  }

  Future<bool> promptInstall() async {
    if (!kIsWeb) return false;
    
    try {
      final result = await js.context.callMethod('promptAppInstall');
      if (result == true) {
        _isInstallable = false;
        _installableController.add(false);
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('❌ [PwaService] Prompt install error: $e');
    }
    return false;
  }
}
