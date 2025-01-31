import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/login_screen.dart';
import 'theme.dart';
import 'dart:async';

/// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

/// Local notifications setup
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Function to show local notification when app is in foreground
void showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'default_channel_id', // Make sure this matches the one in manifest
    'Default Channel',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title ?? "New Notification",
    message.notification?.body ?? "",
    platformChannelSpecifics,
  );
}

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint(details.exceptionAsString());
    Zone.current.handleUncaughtError(details.exception, details.stack!);
  };

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();

    // Initialize Local Notifications
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Notification permission granted!");
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("New FCM message received in foreground: ${message.notification?.title}");
      showLocalNotification(message); // Show local notification in foreground
    });

    // Handle background messages when app is reopened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked!");
    });

    // Subscribe to a topic (optional)
    await FirebaseMessaging.instance.subscribeToTopic("general_notifications");
    print("Subscribed to general notifications!");

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get FCM device token
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Device Token: $token");
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }

  runZonedGuarded(
        () => runApp(const ResourceBookingApp()),
        (error, stackTrace) {
      debugPrint("Uncaught error: $error");
    },
  );
}

class ResourceBookingApp extends StatelessWidget {
  const ResourceBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resource Booking App',
      theme: appTheme,
      home: const LoginScreen(),
    );
  }
}
