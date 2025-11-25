import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/// Currency utility for formatting prices
class CurrencyUtils {
  
  /// Get currency symbol from AppState
  /// Returns '\$' as default if not found
  static String getCurrencySymbol(String? country) {
    // This is now handled by AppState, but we keep this static method
    // for backward compatibility where context isn't available.
    // Ideally, widgets should use context.read<AppState>().currencySymbol
    return '\$'; 
  }
  
  /// Format price with currency symbol
  static String formatPrice(double price, String? country) {
    // We can't access AppState here without context.
    // This method should be deprecated in favor of AppState.formatMoney
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(price);
  }
}
