/// API configuration for environment-specific settings
class ApiConfig {
  /// Base URL for the API
  /// Can be overridden with --dart-define=API_HOST=https://api.tiknetafrica.com
  static const String apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'https://api.tiknetafrica.com',
  );

  /// Full base URL including version path
  static String get baseUrl => '$apiHost/v1';

  /// Feature flag to enable/disable remote API integration
  /// Set to false to use mock data during development/testing
  /// TEMPORARY: Hardcoded to true for web builds (bool.fromEnvironment doesn't work reliably on web)
  static const bool useRemoteApi = true; // bool.fromEnvironment('USE_REMOTE_API', defaultValue: true);

  /// External CRM API Configuration
  static const String crmApiKey = String.fromEnvironment(
    'CRM_API_KEY',
    defaultValue: 'aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE',
  );
  
  /// Coleah CRM Partner API Base URL
  static const String crmBaseUrl = 'https://api.coleah.com/api/cases/external/cases/';
  
  /// New CRM Message endpoint (Tiknet - keeping for reference if needed elsewhere)
  static String get tiknetCrmMessageUrl => '$apiHost/api/comms/external/messages/';
}
