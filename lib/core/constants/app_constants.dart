/// App-wide constants
/// Centralized location for all application constants
class AppConstants {
  // App Info
  /// Application name
  static const String appName = 'CP';

  // Storage Keys
  /// Hive box name for local storage
  static const String hiveBoxName = 'app_storage';

  /// Prefix for secure storage keys
  static const String secureStorageKeyPrefix = 'secure_';

  // API Configuration
  /// Base URL for API requests
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Connection timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Receive timeout duration
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Notification Channels
  /// Default notification channel ID for Android
  static const String defaultNotificationChannelId = 'default_channel';

  /// Default notification channel name
  static const String defaultNotificationChannelName = 'Default Notifications';

  /// Default notification channel description
  static const String defaultNotificationChannelDescription =
      'Default notification channel';
}
