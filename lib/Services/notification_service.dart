import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Repo/notification_repo.dart';
import '../Services/notification_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    log("Handling a background message: ${message.messageId}, data: ${message.data}");
  } catch (e) {
    log("Background handler error: $e");
  }
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationRepo _notificationRepo = NotificationRepo();

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications.';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Request notification permissions
      await requestPermission();

      // 2. Setup iOS foreground presentation options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Initialize local notification channel for Android
      await _initializeLocalNotifications();

      // 4. Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 5. Listen to background message click (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("Notification clicked in background: ${message.data}");
        NotificationRouter.routeNotification(message.data);
      });

      // 6. Check for initial message (when app was terminated)
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        log("App opened from terminated state via notification: ${initialMessage.data}");
        NotificationRouter.setPendingNotification(initialMessage.data);
      }

      // 7. Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((String newToken) async {
        log("FCM Token refreshed: $newToken");
        await _onTokenRefresh(newToken);
      });
    } catch (e) {
      log("NotificationService initialization error: $e");
    }
  }

  Future<void> requestPermission() async {
    try {
      final NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log("Notification authorization status: ${settings.authorizationStatus}");

      if (Platform.isAndroid) {
        final androidImplementation = _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
      }
    } catch (e) {
      log("Error requesting notification permission: $e");
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            log("Local notification tapped with payload: $data");
            NotificationRouter.routeNotification(data);
          } catch (e) {
            log("Error decoding local notification payload: $e");
          }
        }
      },
    );

    // Create high importance Android channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log("Foreground message received: ${message.notification?.title}, data: ${message.data}");

    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    // Show local notification if message contains a notification object
    if (notification != null) {
      final String payloadString = jsonEncode(message.data);

      await _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title ?? 'Divine Foundation',
        body: notification.body ?? '',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payloadString,
      );
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        log("APNs token: $apnsToken");
      }
      final String? token = await _firebaseMessaging.getToken();
      log("FCM Device Token: $token");
      return token;
    } catch (e) {
      log("Error fetching FCM device token: $e");
      return null;
    }
  }

  Future<void> registerDeviceTokenWithBackend() async {
    try {
      final String? token = await getDeviceToken();
      if (token == null || token.isEmpty) {
        log("FCM token is empty, skipping backend registration.");
        return;
      }

      final String platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
      final bool success = await _notificationRepo.registerDeviceTokenApi(
        deviceToken: token,
        platform: platform,
      );

      log("FCM Token registered with backend: $success");
    } catch (e) {
      log("Error registering device token with backend: $e");
    }
  }

  Future<void> removeDeviceTokenFromBackend() async {
    try {
      final String? token = await getDeviceToken();
      if (token != null && token.isNotEmpty) {
        await _notificationRepo.removeDeviceTokenApi(deviceToken: token);
      }
    } catch (e) {
      log("Error removing device token from backend: $e");
    }
  }

  Future<void> _onTokenRefresh(String newToken) async {
    try {
      final String platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
      await _notificationRepo.registerDeviceTokenApi(
        deviceToken: newToken,
        platform: platform,
      );
    } catch (e) {
      log("Error syncing refreshed token with backend: $e");
    }
  }
}
