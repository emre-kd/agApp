// verify_code.dart
import 'dart:async';
import 'package:agapp/controllers/authentication.dart';
import 'package:agapp/screens/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyCode extends StatefulWidget {
  final String email;
  const VerifyCode({super.key, required this.email});

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final TextEditingController codeController = TextEditingController();
  final AuthenticationController _authController = Get.find<AuthenticationController>();
  int _remainingTime = 900; // 15 minutes in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
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
    codeController.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyCode() async {
    final response = await _authController.verifyResetCode(widget.email, codeController.text.trim(), context);
    if (response != null && response['reset_token'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPassword(
            email: widget.email,
            resetToken: response['reset_token'],
          ),
        ),
      );
    }
  }

  Future<void> _resendResetCode() async {
    final success = await _authController.resendResetCode(widget.email, context);
    if (success) {
      setState(() => _remainingTime = 900); // Reset timer on success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kodu Doğrula',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'E-postanıza gönderilen doğrulama kodunu girin: ${widget.email}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kalan süre: ${formatTime(_remainingTime)}',
                style: TextStyle(
                  color: _remainingTime < 60 ? Colors.red : Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => TextField(
                    controller: codeController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                
                    decoration: InputDecoration(
                      labelText: 'Doğrulama Kodu',
                      labelStyle: const TextStyle(color: Colors.white),
                      helperText: _authController.errors['code'],
                      helperStyle: TextStyle(
                        color: _authController.errors['code'] != null ? Colors.red : Colors.white,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _authController.errors['code'] != null ? Colors.red : Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _authController.errors['code'] != null ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              Center(
                child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      onPressed: _authController.isLoading.value || _remainingTime <= 0
                          ? null
                          : _verifyCode,
                      child: _authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Kodu Doğrula'),
                    )),
              ),
              const SizedBox(height: 10),
              Center(
                child: Obx(() => TextButton(
                      onPressed: _authController.isLoading.value || _remainingTime <= 0
                          ? null
                          : _resendResetCode,
                      child: const Text(
                        'Kodu Tekrar Gönder',
                        style: TextStyle(color: Colors.blue),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}