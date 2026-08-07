import 'dart:async';
import 'dart:js_interop';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'pwa_service.dart';

@JS('onAppInstallable')
external set onAppInstallable(JSFunction value);

@JS('onAppInstalled')
external set onAppInstalled(JSFunction value);

@JS('onPwaUpdateAvailable')
external set onPwaUpdateAvailable(JSFunction value);

@JS('isAppInstallable')
external JSBoolean isAppInstallableJs();

@JS('isInstallPromptSupported')
external JSBoolean isInstallPromptSupportedJs();

@JS('isStandalone')
external JSBoolean isStandaloneJs();

@JS('promptAppInstall')
external JSPromise<JSBoolean> promptAppInstallJs();

@JS('applyPwaUpdate')
external void applyPwaUpdateJs();

@JS('pwaUpdateAvailable')
external JSBoolean? pwaUpdateAvailableJs();

class PwaServiceWeb implements PwaService {
  static final PwaServiceWeb _instance = PwaServiceWeb._internal();
  factory PwaServiceWeb() => _instance;
  PwaServiceWeb._internal();

  final _installableController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get installableStream => _installableController.stream;

  final _updateAvailableController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get updateAvailableStream => _updateAvailableController.stream;

  bool _isInstallable = false;
  @override
  bool get isInstallable => _isInstallable;

  bool _isUpdateAvailable = false;
  @override
  bool get isUpdateAvailable => _isUpdateAvailable;

  @override
  bool get isInstallPromptSupported {
    try {
      return isInstallPromptSupportedJs().toDart;
    } catch (e) {
      return false;
    }
  }

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

    onPwaUpdateAvailable = (() {
      _isUpdateAvailable = true;
      _updateAvailableController.add(true);
      if (kDebugMode) debugPrint('🌐 [PwaService] New update available!');
    }).toJS;

    // Check initial installable state
    try {
      _isInstallable = isAppInstallableJs().toDart && !isStandalone;
    } catch (e) {
      _isInstallable = false;
    }
    _installableController.add(_isInstallable);

    // Check initial update available state
    try {
      final updateAvail = pwaUpdateAvailableJs();
      if (updateAvail != null && updateAvail.toDart) {
        _isUpdateAvailable = true;
        _updateAvailableController.add(true);
      }
    } catch (e) {
      _isUpdateAvailable = false;
    }
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
      if (kDebugMode) debugPrint('❌ [PwaService] Prompt install error: $e');
    }
    return false;
  }

  @override
  Future<void> applyUpdate() async {
    try {
      applyPwaUpdateJs();
    } catch (e) {
      html.window.location.reload();
    }
  }
}

// Global factory for PwaService
PwaService getPwaService() => PwaServiceWeb();
