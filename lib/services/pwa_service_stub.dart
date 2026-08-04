import 'dart:async';
import 'pwa_service.dart';

PwaService getPwaService() => PwaServiceStub();

class PwaServiceStub implements PwaService {
  static final PwaServiceStub _instance = PwaServiceStub._internal();
  factory PwaServiceStub() => _instance;
  PwaServiceStub._internal();

  final _installableController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get installableStream => _installableController.stream;

  @override
  bool get isInstallable => false;

  @override
  bool get isInstallPromptSupported => false;

  @override
  bool get isStandalone => false;

  @override
  bool get isIOS => false;

  @override
  void init() {}

  @override
  Future<bool> promptInstall() async => false;
}
