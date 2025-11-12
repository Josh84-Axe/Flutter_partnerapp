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
  static const bool useRemoteApi = bool.fromEnvironment(
    'USE_REMOTE_API',
    defaultValue: true, // Enabled for API integration testing
  );
}
