class HotspotConfigurationService {
  static List<String> getRateLimits() {
    return ['10 Mbps (Basic)', '50 Mbps (Standard)', '100 Mbps (Premium)'];
  }

  static List<String> getIdleTimeouts() {
    return ['15 minutes', '30 minutes', '60 minutes'];
  }

  static List<String> getValidityOptions() {
    return ['1 day (Daily)', '7 days (Weekly)', '30 days (Monthly)'];
  }

  static List<String> getDataLimits() {
    return ['10 GB', '50 GB', 'Unlimited'];
  }

  static List<String> getSpeedOptions() {
    return ['10 Mbps', '50 Mbps', '100 Mbps'];
  }

  static List<String> getDeviceAllowed() {
    return ['1 device', '3 devices', '5 devices'];
  }

  static List<String> getSharedUsers() {
    return ['1 user (Single)', '5 users (Family)', '10 users (Business)'];
  }

  static List<String> getUserProfiles() {
    return ['Basic', 'Standard', 'Premium', 'Ultra'];
  }

  static int extractNumericValue(String option) {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(option);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  static bool isUnlimited(String option) {
    return option.toLowerCase().contains('unlimited');
  }
}
