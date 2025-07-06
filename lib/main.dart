import 'dart:convert';

import 'package:agapp/models/post.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/login.dart';
import 'package:agapp/screens/profile.dart';
import 'package:agapp/screens/comments_page.dart'; // Yönlendirme için gerekli
import 'package:agapp/screens/chat.dart'; // Chat sayfası için import ekle
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Flutter Local Notifications setup
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Navigator için global key (context dışından navigasyon için)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'Yüksek Önemli Bildirimler', // name
  description: 'Yüksek öncelikli bildirimler için kanal', // description
  importance: Importance.high,
);

// 🔥 Aktif chat ekranındaki kullanıcı ID'sini tutacak global değişken
String? activeChatUserId;

Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        try {
          final data = jsonDecode(payload);
          debugPrint('Bildirim tıklama payload a:  $activeChatUserId');

          if (data['post'] != null) {
            // Yorum bildirimi
            final postJson = jsonDecode(data['post']);
            final post = Post.fromJson(postJson);

            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => CommentsPage(
                post: post,
                currentUserId: post.userId,
                parentScreen: 'notification',
              ),
            ));
          } else if (data['sender_id'] != null) {
            // Chat bildirimi
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => Chat(
                userId: data['sender_id'].toString(),
                userName: data['sender_name'] ?? 'Sohbet',
              ),
            ));
          }
        } catch (e) {
          debugPrint('Bildirim tıklama payload hatası: $e');
        }
      }
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> sendFcmTokenToBackend(String token) async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('token');
  if (authToken == null) return;

  // Backend'e token gönderme işlemini burada yap
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final localToken = prefs.getString('token');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupFlutterNotifications();

  // FCM token al ve backend'e gönder
  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("📱 Firebase Token: $fcmToken");
  if (fcmToken != null) {
    await sendFcmTokenToBackend(fcmToken);
  }

  // Foreground'da bildirim geldiğinde local notification göster
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    // final data = message.data;

    // debugPrint('Foreground bildirim alındı:  ${data['sender_id']}   ${data['reciever_id']}');
   /* debugPrint('Foreground bildirim alındı: $activeChatUserId'
        ' ${data['sender_id']} ');

    if (activeChatUserId != null && data['sender_id'] == activeChatUserId) {
      debugPrint('Bildirim engellendi çünkü kullanıcı zaten bu kişiyle chat ekranında.');
      return;
    }
    */

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
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data), // Burada payload'u ekledik
      );
    }
  });

  // Uygulama background'da veya kapalıyken bildirime tıklama ile açılırsa:
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = message.data;

    if (data['post'] != null) {
      final postJson = jsonDecode(data['post']);
      final post = Post.fromJson(postJson);

      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => CommentsPage(
          post: post,
          currentUserId: post.userId,
          parentScreen: 'notification',
        ),
      ));
    } else if (data['sender_id'] != null) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => Chat(
          userId: data['sender_id'].toString(),
          userName: data['sender_name'] ?? 'Sohbet',
        ),
      ));
    }
  });

  runApp(
    MyApp(initialScreen: localToken != null ? const Home() : const Login()),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Navigator key'i ekledik
      debugShowCheckedModeBanner: false,
      home: initialScreen,
      routes: {
        '/home': (context) => const Home(),
        '/profile': (context) => const Profile(),
      },
      theme: ThemeData(textTheme: GoogleFonts.tekturTextTheme()),
    );
  }
}
