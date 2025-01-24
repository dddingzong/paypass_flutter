import 'package:flutter/services.dart';

Future<void> createNotificationChannel() async {
  const MethodChannel channel = MethodChannel('com.app.channel');
  try {
    await channel.invokeMethod('createNotificationChannel', {
      'id': 'com.app.geofencing_notifications_channel', // 사용하려는 채널 ID
      'name': 'Geofencing Notifications',
      'description': 'Notifications for geofencing service',
      'importance': 3, // 중요도(0~4, 3은 기본값)
    });
  } on PlatformException catch (e) {
    print("Error creating notification channel: ${e.message}");
  }
}
