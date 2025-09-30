import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

typedef CallActionCallback = void Function(String action);

class CallNotificationService {
  static final CallNotificationService _instance = CallNotificationService._internal();
  factory CallNotificationService() => _instance;
  CallNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  CallActionCallback? _callback;
  bool _isInitialized = false;


  Future<void> init({required CallActionCallback onAction}) async {
    if (_isInitialized) return;

    _callback = onAction;

    // Request notification permissions first
    await _requestPermissions();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    final initialized = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final actionId = response.actionId;
        if (actionId?.isNotEmpty == true) {
          _callback?.call(actionId!);
        } else if (response.payload?.isNotEmpty == true) {
 
          _callback?.call('OPEN');
        }
      },
    );

    if (initialized == true) {
      _isInitialized = true;
      

      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }
    }
  }


  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {

      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      
    } else if (Platform.isIOS) {

      await Permission.notification.request();
    }
  }


  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'call_channel',
      'Incoming Calls',
      description: 'Notifications for incoming calls',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show incoming call notification
  Future<void> showIncomingCallNotification({
    required String callerName,
    required String callType,
  }) async {
    if (!_isInitialized) {
      print('CallNotificationService not initialized. Call init() first.');
      return;
    }

    // Check if we have permission
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        print('Notification permission not granted');
        await Permission.notification.request();
      }
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'call_channel',
      'Incoming Calls',
      channelDescription: 'Notifications for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.call,
      styleInformation: BigTextStyleInformation(
        'Incoming $callType call from $callerName',
        contentTitle: 'Incoming $callType Call',
      ),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'ACCEPT',
          'Accept',
          showsUserInterface: true,
          cancelNotification: true,
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        AndroidNotificationAction(
          'REJECT',
          'Reject',
          showsUserInterface: true,
          cancelNotification: true,
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
      categoryIdentifier: 'CALL_CATEGORY',
    );

    final NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notifications.show(
        0,
        'Incoming $callType Call',
        'Call from $callerName',
        details,
        payload: 'INCOMING_CALL',
      );
   
    } catch (e) {

    }
  }


  Future<void> cancelNotification() async {
    try {
      await _notifications.cancel(0);
      print('Notification cancelled');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {

    }
  }


  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS) {
      return await Permission.notification.isGranted;
    }
    return false;
  }

  void dispose() {
    _callback = null;
  }
}