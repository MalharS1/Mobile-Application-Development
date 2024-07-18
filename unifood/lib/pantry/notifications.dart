import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unifood/DemoLocalizations.dart';

class Notifications {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationDetails androidPlatformChannelSpecifics; // Declare AndroidNotificationDetails at the class level

  // Constructor
  Notifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializeNotifications();
  }

  // Initialization of notifications
  void initializeNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Define AndroidNotificationDetails for reuse in scheduling notifications
    androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      // Set priority and importance to high
      importance: Importance.high,
      priority: Priority.high,
      icon: 'app_icon',
    );
  }

  // Variables to count notification id
  int idScheduled = 0;
  int idInstant = 0;

  // Method for scheduled notifications
  Future<void> scheduleNotification(
      String itemName, DateTime scheduledDate, var context) async {
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Notification displays item name and when the notification was displayed
    // Enabled in settings to show on screen when the phone is on
    await flutterLocalNotificationsPlugin.zonedSchedule(
      idScheduled++, // Increment ID for each new notification

      // Notification title along with information about item expiry
      DemoLocalizations.of(context).scheduledNoti,
      '"$itemName" ${DemoLocalizations.of(context).expires} ${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Allow the notification to be shown even when the device is in low-power idle modes.
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, // Used to give exact date and time
    );
  }

  // Method to show immediate notifications for invalid items
  void showImmediateNotificationInvalid(String itemName) async {
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show immediate notification
    await flutterLocalNotificationsPlugin.show(
      idInstant++,
      'Invalid Item',
      '"$itemName" Already Exists',
      platformChannelSpecifics,
      payload: 'Pantry Item Not Added',
    );
  }

  // Method to show immediate notifications for incorrect time
  void showImmediateNotificationIncorrectTime(String itemName) async {
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show immediate notification
    await flutterLocalNotificationsPlugin.show(
      idInstant++,
      'Incorrect time',
      'Please Choose a valid time',
      platformChannelSpecifics,
      payload: 'Incorrect time selection',
    );
  }
}
