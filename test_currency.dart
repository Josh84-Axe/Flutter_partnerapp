void main() {
  String normalizeCurrencyCode(String code) {
    switch (code) {
      case 'GH₵': 
      case 'GHS': return 'GHS';
      case 'KSh': 
      case 'KES': return 'KES';
      case 'FG': 
      case 'GNF': return 'GNF';
      case 'CFA': 
      case 'XOF': return 'XOF';
      case 'XAF': return 'XAF';
      case '₦': 
      case 'NGN': return 'NGN';
      case 'USh': 
      case 'UGX': return 'UGX';
      case 'TSh': 
      case 'TZS': return 'TZS';
      case 'RF': 
      case 'RWF': return 'RWF';
      case 'R': 
      case 'ZAR': return 'ZAR';
      case '\$': 
      case 'USD': return 'USD';
      default: return code.length == 3 ? code : 'NGN';
    }
  }

  print("Result for '₦': " + normalizeCurrencyCode('₦'));
  print("Result for 'NGN': " + normalizeCurrencyCode('NGN'));
}
