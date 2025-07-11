import 'dart:convert';

import 'package:agapp/main.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.forward();

    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final initialData = prefs.getString('initial_notification_data');

    if (!mounted) return;

    if (initialData != null) {
      final data = jsonDecode(initialData);
      prefs.remove('initial_notification_data');
      handleNotificationTap(data); // Zaten pushReplacement var
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => token != null ? const Home() : const Login(),
      ),
    );
  }



  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Animated app title
           

            // App logo
            Center(
              child: Image.asset(
                'assets/logo.png',
                width: size.width * 0.45,
                height: size.width * 0.45,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
 AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'agalarnediyor.com',
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.02,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
            ),
            const SizedBox(height: 40),
            const Spacer(),

            // Custom-styled progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation(
                        const Color.fromARGB(255, 255, 255, 255), // Teal-ish gradient feel
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),
 
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'emrekaradereli.dev',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: size.width * 0.015,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
