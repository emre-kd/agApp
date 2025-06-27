// verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agapp/controllers/authentication.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String username;
  const VerificationScreen({super.key, required this.email, required this.username});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController codeController = TextEditingController();
  final AuthenticationController _authController = Get.find();
  int _remainingTime = 900; // 15 minutes in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification code sent to ${widget.email}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Time remaining: ${formatTime(_remainingTime)}',
              style: TextStyle(
                color: _remainingTime < 60 ? Colors.red : Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return _authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _remainingTime <= 0
                          ? null
                          : () {
                              _authController.verifyRegistration(
                                code: codeController.text,
                                context: context, 
                                email: widget.email,
                                 username: widget.username,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _remainingTime <= 0 ? Colors.grey : Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Verify'),
                    );
            }),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Resend code logic
                _authController.resendVerificationCode(widget.email, context);
                setState(() => _remainingTime = 900);
              },
              child: const Text(
                'Resend Code',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}