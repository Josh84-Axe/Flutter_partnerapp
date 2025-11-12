/// Currency utility for mapping countries to their official currency symbols
class CurrencyUtils {
  /// Map of country names to their official currency symbols
  static const Map<String, String> countryCurrencyMap = {
    // North America
    'United States': '\$',
    'Canada': 'CA\$',
    'Mexico': 'MX\$',
    
    // Europe
    'France': '€',
    'Belgium': '€',
    'Germany': '€',
    'Spain': '€',
    'Italy': '€',
    'United Kingdom': '£',
    'Switzerland': 'CHF',
    'Netherlands': '€',
    'Portugal': '€',
    'Austria': '€',
    'Ireland': '€',
    'Greece': '€',
    'Poland': 'zł',
    'Sweden': 'kr',
    'Norway': 'kr',
    'Denmark': 'kr',
    
    // Africa
    'Ivory Coast': 'CFA',
    'Senegal': 'CFA',
    'Nigeria': '₦',
    'Ghana': 'GH₵',
    'Kenya': 'KSh',
    'South Africa': 'R',
    'Egypt': 'E£',
    'Morocco': 'MAD',
    'Tunisia': 'DT',
    'Algeria': 'DA',
    'Cameroon': 'CFA',
    'Mali': 'CFA',
    'Burkina Faso': 'CFA',
    'Niger': 'CFA',
    'Benin': 'CFA',
    'Togo': 'CFA',
    'Guinea': 'GNF',
    
    // Asia
    'China': '¥',
    'Japan': '¥',
    'India': '₹',
    'South Korea': '₩',
    'Singapore': 'S\$',
    'Thailand': '฿',
    'Malaysia': 'RM',
    'Indonesia': 'Rp',
    'Philippines': '₱',
    'Vietnam': '₫',
    
    // Middle East
    'United Arab Emirates': 'AED',
    'Saudi Arabia': 'SAR',
    'Qatar': 'QAR',
    'Kuwait': 'KWD',
    'Israel': '₪',
    'Turkey': '₺',
    
    // South America
    'Brazil': 'R\$',
    'Argentina': 'AR\$',
    'Chile': 'CL\$',
    'Colombia': 'CO\$',
    'Peru': 'S/',
    
    // Oceania
    'Australia': 'A\$',
    'New Zealand': 'NZ\$',
  };
  
  /// Get currency symbol for a given country
  /// Returns '\$' as default if country is not found
  static String getCurrencySymbol(String? country) {
    if (country == null || country.isEmpty) {
      return '\$'; // Default to USD
    }
    return countryCurrencyMap[country] ?? '\$';
  }
  
  /// Format price with currency symbol
  static String formatPrice(double price, String? country) {
    final symbol = getCurrencySymbol(country);
    return '$symbol${price.toStringAsFixed(2)}';
  }
}
