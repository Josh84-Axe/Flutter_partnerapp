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
}
