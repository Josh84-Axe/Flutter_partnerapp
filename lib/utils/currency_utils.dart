import 'package:intl/intl.dart';

/// Currency utility for formatting prices
class CurrencyUtils {
  
  /// Get currency code for a given country
  static String getCurrencyCode(String? country) {
    if (country == null || country.isEmpty) return 'USD';
    
    final normalized = country.trim().toLowerCase();
    
    // Robust substring matching
    if (normalized.contains('guinea') && !normalized.contains('bissau')) return 'GNF';
    if (normalized.contains('ghana')) return 'GHS';
    if (normalized.contains('nigeria')) return 'NGN';
    if (normalized.contains('kenya')) return 'KES';
    if (normalized.contains('uganda')) return 'UGX';
    if (normalized.contains('tanzania')) return 'TZS';
    if (normalized.contains('rwanda')) return 'RWF';
    if (normalized.contains('south africa')) return 'ZAR';
    
    // XOF Countries
    if (normalized.contains('senegal') || 
        normalized.contains('ivory coast') || 
        normalized.contains('cote d\'ivoire') ||
        normalized.contains('benin') ||
        normalized.contains('burkina') ||
        normalized.contains('mali') ||
        normalized.contains('niger') ||
        normalized.contains('togo')) return 'XOF';
        
    // XAF Countries
    if (normalized.contains('cameroon') ||
        normalized.contains('chad') ||
        normalized.contains('gabon') ||
        normalized.contains('congo') ||
        normalized.contains('equatorial guinea') ||
        normalized.contains('central african republic')) return 'XAF';

    return 'USD';
  }

  /// Get currency symbol/label for a given country
  static String getCurrencySymbol(String? country) {
    final code = getCurrencyCode(country);
    switch (code) {
      case 'GHS': return 'GHS';
      case 'XOF': 
      case 'XAF': return 'CFA';
      case 'NGN': return '₦';
      case 'KES': return 'KSh';
      case 'UGX': return 'USh';
      case 'TZS': return 'TSh';
      case 'RWF': return 'RF';
      case 'ZAR': return 'R';
      case 'GNF': return 'FG';
      case 'USD': return '\$';
      default: return code;
    }
  }
  
  /// Safely parse amount from API response (handles both int and double, strings)
  static double parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
  
  /// Format price with currency symbol based on country
  /// 
  /// Examples:
  /// - Ghana: GHS 2,500.00
  /// - Ivory Coast: 1.000 CFA
  /// - Guinea: 25.000 FG
  /// - USA: $2,500.00
  static String formatPrice(double price, String? country, {String? currencyCode}) {
    // If currencyCode is provided, use it directly (e.g. from API)
    // Otherwise fallback to country-based lookup
    final code = currencyCode ?? getCurrencyCode(country);
    
    // Determine symbol based on code
    final symbol = getCurrencySymbol(country);

    // Currencies with no decimals
    const zeroDecimalCodes = {'XOF', 'XAF', 'GNF', 'UGX', 'RWF', 'TZS'};
    
    if (zeroDecimalCodes.contains(code)) {
      final amount = price.round();
      // Manually format with dot thousands separator to avoid dependency on 'de_DE' locale data on Web
      final String raw = amount.toString();
      final StringBuffer buffer = StringBuffer();
      for (int i = 0; i < raw.length; i++) {
        if (i > 0 && (raw.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(raw[i]);
      }
      final formattedNumber = buffer.toString();
      return '$formattedNumber $symbol'; // Suffix: 1.000 CFA or 25.000 FG
    } else {
      // Standard 2-decimal formatting (comma separator)
      // Use 'en_US' explicitly to ensure consistent decimal/thousands separators
      final formatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: '',
        decimalDigits: 2,
      );
      final formattedNumber = formatter.format(price).trim();
      
      // Special spacing for GHS and others that use 3-letter codes
      if (symbol.length > 1) {
        return '$symbol $formattedNumber'; // GHS 2,500.00
      } else {
        return '$symbol$formattedNumber'; // $2,500.00
      }
    }
  }
}
