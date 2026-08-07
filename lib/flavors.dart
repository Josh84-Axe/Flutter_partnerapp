import 'package:flutter/foundation.dart';

enum Flavor {
  partner,
  family,
  campus,
}

class F {
  static Flavor? _appFlavor;

  static Flavor get appFlavor {
    if (_appFlavor != null) return _appFlavor!;
    
    // 1. Check compile-time environment variable first
    const envVariant = String.fromEnvironment('APP_VARIANT');
    if (envVariant == 'family') return Flavor.family;
    if (envVariant == 'campus') return Flavor.campus;
    if (envVariant == 'partner') return Flavor.partner;

    // 2. Check hostname for web
    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host.contains('family')) {
        return Flavor.family;
      } else if (host.contains('campus')) {
        return Flavor.campus;
      }
    }
    return Flavor.partner;
  }

  static set appFlavor(Flavor? flavor) {
    _appFlavor = flavor;
  }

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.partner:
        return 'Tiknet Partner';
      case Flavor.family:
        return 'Tiknet Family';
      case Flavor.campus:
        return 'Tiknet Campus';
    }
  }

  static String get iconAsset {
    switch (appFlavor) {
      case Flavor.family:
        return 'assets/icons/family_app_icon.png';
      case Flavor.campus:
        return 'assets/icons/campus_app_icon.png';
      case Flavor.partner:
        return 'assets/icons/partner_app_icon.png';
    }
  }
}
