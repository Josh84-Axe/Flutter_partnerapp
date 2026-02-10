import 'dart:async';
import 'dart:js_interop';
import 'dart:js_util' as js_util;
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'pwa_service.dart';

@JS('isAppInstallable')
external JSBoolean isAppInstallableJs();

@JS('promptAppInstall')
external JSPromise<JSBoolean> promptAppInstallJs();

class PwaServiceWeb implements PwaService {
  static final PwaServiceWeb _instance = PwaServiceWeb._internal();
  factory PwaServiceWeb() => _instance;
  PwaServiceWeb._internal();

  final _installableController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get installableStream => _installableController.stream;

  bool _isInstallable = false;
  @override
  bool get isInstallable => _isInstallable;

  @override
  void init() {
    // Register callback for JS using dart:js_util (more reliable for window properties)
    js_util.setProperty(html.window, 'onAppInstallable', () {
      _isInstallable = true;
      _installableController.add(true);
      if (kDebugMode) print('🌐 [PwaService] App is installable');
    });

    // Check initial state
    try {
      _isInstallable = isAppInstallableJs().toDart;
    } catch (e) {
      if (kDebugMode) print('⚠️ [PwaService] Initial check failed (expected on non-PWA): $e');
      _isInstallable = false;
    }
    _installableController.add(_isInstallable);
  }

  @override
  Future<bool> promptInstall() async {
    try {
      final JSBoolean result = await promptAppInstallJs().toDart;
      if (result.toDart) {
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

// Global factory for PwaService
PwaService getPwaService() => PwaServiceWeb();
