import 'dart:async';
import 'pwa_service_stub.dart'
    if (dart.library.js) 'pwa_service_web.dart';

abstract class PwaService {
  static final PwaService _instance = getPwaService();
  factory PwaService() => _instance;

  Stream<bool> get installableStream;
  bool get isInstallable;
  bool get isInstallPromptSupported;
  bool get isStandalone;
  bool get isIOS;
  void init();
  Future<bool> promptInstall();
}
