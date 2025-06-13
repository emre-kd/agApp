import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/login.dart';
import 'package:agapp/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  debugPrint('Token: $token'); // Print token to debug console

  runApp(MyApp(initialRoute: token != null ? Home() : Login()));
}

class MyApp extends StatelessWidget {
  final Widget initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.tektur(), // Apply to bodyText1
          bodyMedium: GoogleFonts.tektur(), // Apply to bodyText2
          displayLarge: GoogleFonts.tektur(), // Apply to headlines
          displayMedium: GoogleFonts.tektur(),
          displaySmall: GoogleFonts.tektur(),
          headlineMedium: GoogleFonts.tektur(),
          headlineSmall: GoogleFonts.tektur(),
          titleLarge: GoogleFonts.tektur(),
          titleMedium: GoogleFonts.tektur(),
          titleSmall: GoogleFonts.tektur(),
          bodySmall: GoogleFonts.tektur(),
          labelLarge: GoogleFonts.tektur(),
          labelSmall: GoogleFonts.tektur(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: initialRoute,
      routes: {
        '/home': (context) => const Home(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}
