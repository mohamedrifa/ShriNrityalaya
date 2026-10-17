/// Defines the client-side version constants for version control
/// and in-app update checks against Firebase Realtime Database.
class AppVersionConstants {
  /// Current installed application version number.
  /// Compare this against "AppVersion" in Firebase Realtime Database.
  static const int currentAppVersion = 1;

  /// Semantic version string for display in UI / about dialogs.
  static const String appVersionName = '1.0.0';

  /// Root node key in Firebase Realtime Database.
  static const String firebaseNode = 'Shrinrityalaya';

  /// Keys in the Firebase Realtime Database object
  static const String keyAppVersion = 'AppVersion';
  static const String keyAppUrl = 'AppUrl';
  static const String keyIsMandatory = 'isMandatoryUpdate';
}
