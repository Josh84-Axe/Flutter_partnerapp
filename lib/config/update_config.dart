class UpdateConfig {
  /// The URL where the app checks for the latest version.
  /// The JSON response should look like:
  /// {
  ///   "latestVersion": "1.0.1",
  ///   "downloadUrl": "https://example.com/app-release.apk",
  ///   "forceUpdate": false,
  ///   "releaseNotes": "Fixes payment bug and adds new features."
  /// }
  static const String versionCheckUrl = 'https://raw.githubusercontent.com/Josh84-Axe/Flutter_partnerapp/fix/token-storage-windows/version.json';
}
