import 'package:intl/intl.dart';

/// Currency utility for formatting prices
class CurrencyUtils {
  
  /// Get currency code for a given country
  static String getCurrencyCode(String? country) {
    if (country == null) return 'USD';
    
    switch (country.toLowerCase()) {
      case 'ghana':
        return 'GHS';
      case 'ivory coast':
      case 'cote d\'ivoire':
      case 'côte d\'ivoire':
      case 'benin':
      case 'burkina faso':
      case 'guinea-bissau':
      case 'mali':
      case 'niger':
      case 'senegal':
      case 'togo':
        return 'XOF'; // CFA Franc BCEAO
      case 'cameroon':
      case 'central african republic':
      case 'chad':
      case 'congo':
      case 'equatorial guinea':
      case 'gabon':
        return 'XAF'; // CFA Franc BEAC
      case 'nigeria':
        return 'NGN';
      case 'kenya':
        return 'KES';
      case 'uganda':
        return 'UGX';
      case 'tanzania':
        return 'TZS';
      case 'rwanda':
        return 'RWF';
      case 'south africa':
        return 'ZAR';
      default:
        return 'USD';
    }
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
      case 'USD': return '\$';
      default: return code;
    }
  }
  
  /// Format price with currency symbol based on country
  /// 
  /// Examples:
  /// - Ghana: GHS 2,500
  /// - Ivory Coast: 1.000 CFA
  /// - USA: $2,500
  static String formatPrice(double price, String? country) {
    final code = getCurrencyCode(country);
    final symbol = getCurrencySymbol(country);
    
    // Round to nearest integer (no decimals)
    final int amount = price.round();
    
    // Create formatter with no decimal digits
    final formatter = NumberFormat.currency(
      symbol: '', // We'll add symbol manually to control placement
      decimalDigits: 0,
    );
    
    // Format the number part
    // Note: NumberFormat automatically handles thousands separators
    // For CFA regions (French locale-ish), they often use dots for thousands, 
    // but standard English locale uses commas. 
    // The user requested "1.000 CFA" for CFA, which implies dot separator.
    
    String formattedNumber;
    
    if (code == 'XOF' || code == 'XAF') {
      // Use custom formatting for CFA to match "1.000" style (dot separator)
      formattedNumber = NumberFormat.decimalPattern('de_DE').format(amount);
      return '$formattedNumber $symbol'; // Suffix: 1.000 CFA
    } else {
      // Standard formatting (comma separator)
      formattedNumber = NumberFormat.decimalPattern('en_US').format(amount);
      
      // Special spacing for GHS and others that use 3-letter codes
      if (symbol.length > 1) {
        return '$symbol $formattedNumber'; // GHS 2,500
      } else {
        return '$symbol$formattedNumber'; // $2,500
      }
    }
  }
}
