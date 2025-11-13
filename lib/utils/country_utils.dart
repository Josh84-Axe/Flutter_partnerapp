/// Utility for country name to ISO code mapping
class CountryUtils {
  /// Map of country names to ISO 3166-1 alpha-2 codes
  /// Focused on African countries and common partner locations
  static const Map<String, String> countryNameToIsoCode = {
    // West Africa
    'Togo': 'TG',
    'Ghana': 'GH',
    'Nigeria': 'NG',
    'Benin': 'BJ',
    'Burkina Faso': 'BF',
    'Ivory Coast': 'CI',
    'Côte d\'Ivoire': 'CI',
    'Senegal': 'SN',
    'Mali': 'ML',
    'Niger': 'NE',
    'Guinea': 'GN',
    'Sierra Leone': 'SL',
    'Liberia': 'LR',
    'Gambia': 'GM',
    'Cape Verde': 'CV',
    'Mauritania': 'MR',
    
    // Central Africa
    'Cameroon': 'CM',
    'Chad': 'TD',
    'Central African Republic': 'CF',
    'Congo': 'CG',
    'Democratic Republic of the Congo': 'CD',
    'Gabon': 'GA',
    'Equatorial Guinea': 'GQ',
    'São Tomé and Príncipe': 'ST',
    
    // East Africa
    'Kenya': 'KE',
    'Tanzania': 'TZ',
    'Uganda': 'UG',
    'Rwanda': 'RW',
    'Burundi': 'BI',
    'Ethiopia': 'ET',
    'Somalia': 'SO',
    'Djibouti': 'DJ',
    'Eritrea': 'ER',
    'South Sudan': 'SS',
    
    // Southern Africa
    'South Africa': 'ZA',
    'Namibia': 'NA',
    'Botswana': 'BW',
    'Zimbabwe': 'ZW',
    'Zambia': 'ZM',
    'Malawi': 'MW',
    'Mozambique': 'MZ',
    'Angola': 'AO',
    'Lesotho': 'LS',
    'Eswatini': 'SZ',
    'Swaziland': 'SZ',
    
    // North Africa
    'Egypt': 'EG',
    'Morocco': 'MA',
    'Algeria': 'DZ',
    'Tunisia': 'TN',
    'Libya': 'LY',
    'Sudan': 'SD',
    
    // Europe (common partner locations)
    'France': 'FR',
    'United Kingdom': 'GB',
    'Germany': 'DE',
    'Spain': 'ES',
    'Italy': 'IT',
    'Portugal': 'PT',
    'Belgium': 'BE',
    'Netherlands': 'NL',
    'Switzerland': 'CH',
    
    // Americas (common partner locations)
    'United States': 'US',
    'Canada': 'CA',
    'Brazil': 'BR',
    
    // Asia (common partner locations)
    'China': 'CN',
    'India': 'IN',
    'Japan': 'JP',
  };
  
  /// Map of ISO codes to country names
  static final Map<String, String> isoCodeToCountryName = 
      countryNameToIsoCode.map((name, code) => MapEntry(code, name));
  
  /// Convert country name to ISO code
  /// Returns the ISO code if found, otherwise returns the input unchanged
  static String getIsoCode(String countryName) {
    // Try exact match first
    if (countryNameToIsoCode.containsKey(countryName)) {
      return countryNameToIsoCode[countryName]!;
    }
    
    // Try case-insensitive match
    final lowerName = countryName.toLowerCase();
    for (final entry in countryNameToIsoCode.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value;
      }
    }
    
    // If already an ISO code (2 letters), return as-is
    if (countryName.length == 2 && countryName.toUpperCase() == countryName) {
      return countryName;
    }
    
    // Return original if no match found
    return countryName;
  }
  
  /// Convert ISO code to country name
  /// Returns the country name if found, otherwise returns the input unchanged
  static String getCountryName(String isoCode) {
    final upperCode = isoCode.toUpperCase();
    if (isoCodeToCountryName.containsKey(upperCode)) {
      return isoCodeToCountryName[upperCode]!;
    }
    return isoCode;
  }
  
  /// Check if a string is a valid ISO code
  static bool isValidIsoCode(String code) {
    return isoCodeToCountryName.containsKey(code.toUpperCase());
  }
  
  /// Get list of all supported country names
  static List<String> getAllCountryNames() {
    return countryNameToIsoCode.keys.toList()..sort();
  }
  
  /// Get list of all supported ISO codes
  static List<String> getAllIsoCodes() {
    return isoCodeToCountryName.keys.toList()..sort();
  }
}
