// reset_password.dart
import 'package:agapp/controllers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  final String resetToken;
  const ResetPassword({super.key, required this.email, required this.resetToken});

  @override
  State<ResetPassword> createState() => _ResetPasswordState(); // Fixed to use _ResetPasswordState
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthenticationController _authController = Get.find<AuthenticationController>();
  bool _obscurePassword = true;

  // Handle password reset submission
  Future<void> _resetPassword() async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Client-side password match check
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreler eşleşmiyor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Clear previous errors
    _authController.errors['newPassword'];
    _authController.errors['newPassword_confirmation'];

    final success = await _authController.resetPassword(
      widget.email,
      password,
      widget.resetToken,
      context,
    );
    if (success) {
      Navigator.popUntil(context, (route) => route.isFirst);
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
          'Yeni Şifre',
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
                'Yeni şifrenizi girin.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => TextField(
                    maxLength: 40, // Consistent with Register screen
                    controller: passwordController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    obscureText: _obscurePassword,
           
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      labelStyle: const TextStyle(color: Colors.white),
                      helperText: _authController.errors['newPassword'],
                      helperStyle: TextStyle(
                        color: _authController.errors['newPassword'] != null ? Colors.red : Colors.white,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _authController.errors['newPassword'] != null ? Colors.red : Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _authController.errors['newPassword'] != null ? Colors.red : Colors.white,
                        ),
                      ),
                      counterStyle: const TextStyle(color: Colors.white),
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() => TextField(
                    maxLength: 40, // Consistent with Register screen
                    controller: confirmPasswordController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    obscureText: _obscurePassword,
                
                    decoration: InputDecoration(
                      labelText: 'Şifreyi Onayla',
                      labelStyle: const TextStyle(color: Colors.white),
                      helperText: _authController.errors['newPassword_confirmation'],
                      helperStyle: TextStyle(
                        color: _authController.errors['newPassword_confirmation'] != null
                            ? Colors.red
                            : Colors.white,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _authController.errors['newPassword_confirmation'] != null
                              ? Colors.red
                              : Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _authController.errors['newPassword_confirmation'] != null
                              ? Colors.red
                              : Colors.white,
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
                      onPressed: _authController.isLoading.value ? null : _resetPassword,
                      child: _authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Şifreyi Değiştir'),
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}