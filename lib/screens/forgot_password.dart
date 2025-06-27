import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();

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
      body: Padding(
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
            TextField(
              controller: emailController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'E-Posta',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                counterStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 90,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 15),
                ),
                onPressed: () {
                  // Placeholder for reset password logic
                },
                child: const Text('Doğrulama Kodu Yolla'),
              ),
            ),
          ],
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