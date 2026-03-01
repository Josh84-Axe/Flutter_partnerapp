import 'dart:async';
import 'dart:js_interop';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'pwa_service.dart';

@JS('onAppInstallable')
external set onAppInstallable(JSFunction value);

@JS('onAppInstalled')
external set onAppInstalled(JSFunction value);

@JS('isAppInstallable')
external JSBoolean isAppInstallableJs();

@JS('isStandalone')
external JSBoolean isStandaloneJs();

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
  bool get isStandalone {
    try {
      return isStandaloneJs().toDart;
    } catch (e) {
      return false;
    }
  }

  @override
  bool get isIOS {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('iphone') || userAgent.contains('ipad') || userAgent.contains('ipod');
  }

  @override
  void init() {
    // Register callback for JS using modern dart:js_interop
    onAppInstallable = (() {
      if (isStandalone) {
        _isInstallable = false;
      } else {
        _isInstallable = true;
      }
      _installableController.add(_isInstallable);
      if (kDebugMode) debugPrint('🌐 [PwaService] App is installable: $_isInstallable');
    }).toJS;

    onAppInstalled = (() {
      _isInstallable = false;
      _installableController.add(false);
      if (kDebugMode) debugPrint('🌐 [PwaService] App was installed');
    }).toJS;

    // Check initial state
    try {
      _isInstallable = isAppInstallableJs().toDart && !isStandalone;
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
