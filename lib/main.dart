import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

// Local notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Save today's open date
void updateLastOpenedDate() async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  prefs.setString('last_opened', now.toIso8601String());

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final ref = FirebaseDatabase.instance
        .ref("User_Knowledge_Base/${user.uid}/last_opened");
    await ref.set(now.toIso8601String());
  }
}

/// Fetch custom notification message for the user
Future<String> getCustomReminderText(String uid) async {
  final ref = FirebaseDatabase.instance.ref("User_Knowledge_Base/$uid");
  final snapshot = await ref.get();

  if (!snapshot.exists) return "Hey! Let's explore something new today.";

  final userData = snapshot.value as Map;
  final subjectMap = userData['Subjects'] as Map?;

  if (subjectMap != null) {
    for (var subject in subjectMap.values) {
      final chapters = subject['Chapters'] as Map?;
      if (chapters != null) {
        for (var chapter in chapters.values) {
          final topics = chapter['Topics'] as Map?;
          if (topics != null) {
            for (var topic in topics.values) {
              final convo = topic['Conversation'] as Map?;
              if (convo != null) {
                final s1 = convo['S1']?['Text'];
                final level = convo['Level'];
                return "Last time you reached level $level. Ready for more?\n\n\"$s1\"";
              }
            }
          }
        }
      }
    }
  }

  return "Hello! Dive back into Concept Cure and keep learning!";
}

/// Notification logic to run daily
void reminderCallback() async {
  print("🔔 Reminder callback triggered at ${DateTime.now()}");

  final prefs = await SharedPreferences.getInstance();
  final lastOpenedStr = prefs.getString('last_opened');
  final lastOpened =
      lastOpenedStr != null ? DateTime.parse(lastOpenedStr) : null;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (lastOpened == null || lastOpened.isBefore(today)) {
    final user = FirebaseAuth.instance.currentUser;
    final message = user != null
        ? await getCustomReminderText(user.uid)
        : 'Open Concept Cure to continue learning!';

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'Reminder to open app',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '📚 Let’s continue!',
      message,
      platformDetails,
    );
  }
}

/// FCM background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AndroidAlarmManager.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Schedule alarm at 7 PM
  final now = DateTime.now();
  final target = DateTime(now.year, now.month, now.day, 17, 35); // 7 PM
  final delay = target.isBefore(now)
      ? target.add(const Duration(days: 1)).difference(now)
      : target.difference(now);

  await AndroidAlarmManager.periodic(
    const Duration(hours: 24),
    0,
    reminderCallback,
    startAt: DateTime.now().add(delay),
    exact: true,
    wakeup: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Concept Cure',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
