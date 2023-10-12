import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _notification = FlutterLocalNotificationsPlugin();

  var notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    ),
  );

  var notificationSettings = const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    ),
  );

  Future<void> initialize() async {
    await _notification.initialize(notificationSettings);
  }

  Future<void> showNotification(RemoteMessage message) async {
    await _notification.show(
      int.parse(message.data['id']),
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
    );
  }
}
