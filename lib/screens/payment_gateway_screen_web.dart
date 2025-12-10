// Export the correct implementation based on platform
export 'payment_gateway_screen_mobile.dart'
    if (dart.library.html) 'payment_gateway_screen_web.dart';
