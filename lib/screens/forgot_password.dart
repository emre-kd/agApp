// forgot_password.dart
import 'package:agapp/controllers/authentication.dart';
import 'package:agapp/screens/verify_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final AuthenticationController _authController = Get.find<AuthenticationController>();

  // Handle form submission
  Future<void> _requestPasswordReset() async {
    final email = emailController.text.trim();
    _authController.errors['email']; // Clear previous errors
    final success = await _authController.requestPasswordReset(email, context);
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyCode(email: email),
        ),
      );
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
          'Şifremi Unuttum',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Şifre sıfırlama bağlantısını almak için e-postanızı girin.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => TextField(
                    maxLength: 40, // Consistent with Register screen
                    controller: emailController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
           
                    decoration: InputDecoration(
                      labelText: 'E-Posta',
                      labelStyle: const TextStyle(color: Colors.white),
                      helperText: _authController.errors['email'],
                      helperStyle: TextStyle(
                        color: _authController.errors['email'] != null ? Colors.red : Colors.white,
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _authController.errors['email'] != null ? Colors.red : Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _authController.errors['email'] != null ? Colors.red : Colors.white,
                        ),
                      ),
                      counterStyle: const TextStyle(color: Colors.white),
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
                      onPressed: _authController.isLoading.value ? null : _requestPasswordReset,
                      child: _authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Şifreni Sıfırla'),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}