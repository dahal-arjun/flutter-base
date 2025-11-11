import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// TODO: Uncomment when Firebase is configured
// import 'package:firebase_messaging/firebase_messaging.dart';

// TODO: Uncomment when Firebase is configured
// import 'firebase_messaging_background_handler.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';

/// Service for handling local and push notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications;
  // Firebase Messaging is optional - can be null if not configured
  final dynamic _firebaseMessaging;

  /// Creates a NotificationService instance
  /// [firebaseMessaging] can be null if Firebase is not configured
  NotificationService(this._localNotifications, this._firebaseMessaging);

  // Initialize local notifications
  Future<void> initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      AppConstants.defaultNotificationChannelId,
      AppConstants.defaultNotificationChannelName,
      description: AppConstants.defaultNotificationChannelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap logic here
    AppLogger.d('Notification tapped', {'payload': response.payload});
  }

  // Show local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.defaultNotificationChannelId,
      AppConstants.defaultNotificationChannelName,
      channelDescription: AppConstants.defaultNotificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // TODO: Uncomment when Firebase is configured
  // Initialize Firebase Messaging
  // Future<void> initializeFirebaseMessaging() async {
  //   try {
  //     // Set background message handler
  //     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  //   } catch (e) {
  //     debugPrint('Firebase Messaging background handler setup failed: $e');
  //     return; // Exit early if Firebase is not configured
  //   }
  //
  //   // Request permission
  //   NotificationSettings settings = await _firebaseMessaging.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //     provisional: false,
  //   );
  //
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     debugPrint('User granted permission');
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     debugPrint('User granted provisional permission');
  //   } else {
  //     debugPrint('User declined or has not accepted permission');
  //   }
  //
  //   // Get FCM token
  //   String? token = await _firebaseMessaging.getToken();
  //   debugPrint('FCM Token: $token');
  //
  //   // Listen to token refresh
  //   _firebaseMessaging.onTokenRefresh.listen((newToken) {
  //     debugPrint('New FCM Token: $newToken');
  //   });
  //
  //   // Handle foreground messages
  //   FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  //
  //   // Handle background messages (when app is in background)
  //   FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  // }
  //
  // // Handle foreground messages
  // void _handleForegroundMessage(RemoteMessage message) {
  //   debugPrint('Foreground message: ${message.messageId}');
  //
  //   // Show local notification when app is in foreground
  //   if (message.notification != null) {
  //     showLocalNotification(
  //       id: message.hashCode,
  //       title: message.notification!.title ?? 'Notification',
  //       body: message.notification!.body ?? '',
  //       payload: message.data.toString(),
  //     );
  //   }
  // }
  //
  // // Handle background messages
  // void _handleBackgroundMessage(RemoteMessage message) {
  //   debugPrint('Background message: ${message.messageId}');
  //   // Handle navigation or other logic when notification is tapped
  // }

  /// Initialize Firebase Messaging (if configured)
  /// This method will log a warning if Firebase is not configured
  Future<void> initializeFirebaseMessaging() async {
    if (_firebaseMessaging == null) {
      AppLogger.w(
        'Firebase Messaging is not configured. Please configure Firebase first.',
      );
      return;
    }
    // TODO: Uncomment when Firebase is configured
    // Implementation will be added when Firebase is set up
    AppLogger.i('Firebase Messaging initialization skipped - not configured');
  }

  // Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
