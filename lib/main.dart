import 'dart:convert';
import 'package:agapp/models/post.dart';
import 'package:agapp/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/profile.dart';
import 'package:agapp/screens/comments_page.dart';
import 'package:agapp/screens/chat.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Yüksek Önemli Bildirimler',
  description: 'Yüksek öncelikli bildirimler için kanal',
  importance: Importance.high,
);

// 🔔 Bildirim izni isteme
Future<void> requestNotificationPermission() async {
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('🔔 Kullanıcı izin durumu: ${settings.authorizationStatus}');
}

// 🧭 Bildirim tıklama işlemleri
void handleNotificationTap(Map<String, dynamic> data) {
  if (data['type'] == 'new_post') {
    navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      builder: (_) => const Home(),
    ));
  } else if (data['post'] != null) {
    final postJson = jsonDecode(data['post']);
    final post = Post.fromJson(postJson);

    navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      builder: (_) => CommentsPage(
        post: post,
        currentUserId: post.userId,
        parentScreen: 'notification',
      ),
    ));
  } else if (data['sender_id'] != null) {
    navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      builder: (_) => Chat(
        userId: data['sender_id'].toString(),
        userName: data['sender_name'] ?? 'Sohbet',
      ),
    ));
  }
}

// 🔧 Local notification kurulumu
Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_notification');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        try {
          final data = jsonDecode(payload);
          handleNotificationTap(data);
        } catch (e) {
          debugPrint('Payload JSON parse hatası: $e');
        }
      }
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// ✅ Backend'e FCM token gönderme
Future<void> sendFcmTokenToBackend(String token) async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('token');
  if (authToken == null) return;

  print('✅ Backend\'e gönderilecek token: $token');
  // TODO: API isteği buraya
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await requestNotificationPermission();
  await setupFlutterNotifications();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("📱 Firebase Token: $fcmToken");
  if (fcmToken != null) {
    await sendFcmTokenToBackend(fcmToken);
  }

  // 🔥 Uygulama açıkken gelen bildirim
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("🔥 Foreground bildirimi alındı: ${message.data}");

    if (message.data['type'] == 'new_post') {
      showNewPostButton.value = true;
      return;
    }

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@drawable/ic_notification',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  });

  // 🧭 Arka planda bildirime tıklama
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotificationTap(message.data);
  });

  // 🚀 Tamamen kapalıyken bildirime tıklayıp açma
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'initial_notification_data', jsonEncode(initialMessage.data));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const Home(),
        '/profile': (context) => const Profile(),
      },
      theme: ThemeData(textTheme: GoogleFonts.tekturTextTheme()),
    );
  }
}
