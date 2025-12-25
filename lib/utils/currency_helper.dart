import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'currency_utils.dart';

class CurrencyHelper {
  static String getCurrencyCode(String? country) {
    // This is now handled by AppState, but we keep this static method
    // for backward compatibility where context isn't available.
    return 'USD';
  }

  static String getCurrencySymbol(String currencyCode) {
    // This is now handled by AppState, but we keep this static method
    // for backward compatibility where context isn't available.
    return '\$';
  }

  static String formatCurrency(double amount, String? partnerCountry) {
    // We can't access AppState here without context.
    // This method should be deprecated in favor of AppState.formatMoney
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }
}
