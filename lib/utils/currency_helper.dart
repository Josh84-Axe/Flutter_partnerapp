import 'package:intl/intl.dart';

class CurrencyHelper {
  static String getCurrencyCode(String? country) {
    if (country == null) return 'USD';
    
    final countryToCurrency = {
      'United States': 'USD',
      'France': 'EUR',
      'Belgium': 'EUR',
      'Canada': 'CAD',
      'Ivory Coast': 'XOF',
      'Senegal': 'XOF',
      'United Kingdom': 'GBP',
      'Germany': 'EUR',
      'Spain': 'EUR',
      'Italy': 'EUR',
      'Nigeria': 'NGN',
      'Ghana': 'GHS',
      'Kenya': 'KES',
      'South Africa': 'ZAR',
    };
    
    return countryToCurrency[country] ?? 'USD';
  }

  static String getCurrencySymbol(String currencyCode) {
    final currencyToSymbol = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'CAD': 'CAD\$',
      'XOF': 'CFA',
      'NGN': '₦',
      'GHS': 'GH₵',
      'KES': 'KSh',
      'ZAR': 'R',
    };
    
    return currencyToSymbol[currencyCode] ?? '\$';
  }

  static String formatCurrency(double amount, String? partnerCountry) {
    final currencyCode = getCurrencyCode(partnerCountry);
    final symbol = getCurrencySymbol(currencyCode);
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }
}
