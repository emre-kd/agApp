import 'package:agapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.tektur(),  // Apply to bodyText1
          bodyMedium: GoogleFonts.tektur(),  // Apply to bodyText2
          displayLarge: GoogleFonts.tektur(),  // Apply to headlines
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
      home: const Login(), // Set HomePage as the start page
    );
  }
}
