import 'package:agapp/controllers/authentication.dart';
import 'package:agapp/screens/forgot_password.dart';
import 'package:agapp/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController loginUsernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();
  final AuthenticationController _authenticationController = Get.put(
    AuthenticationController(),
  );
  bool _obscurePassword = true; // For toggling password visibility

  // Functions
  void loginUser() async {
    await _authenticationController.login(
      loginUsername: loginUsernameController.text.trim(),
      loginPassword: loginPasswordController.text.trim(),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Padding(
        padding: const EdgeInsets.only(top: 100, right: 15, left: 15),
        child: Column(
          children: [
            Image.asset("assets/logo.png", height: 120),
            const SizedBox(height: 20),

            Obx(() {
              return TextField(
                maxLength: 20,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                controller: loginUsernameController,

                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  labelStyle: TextStyle(color: Colors.white),
                  helperText:
                      _authenticationController.errors['loginUsername'] ??
                      _authenticationController.errors['loginUsername'],
                  helperStyle: TextStyle(
                    color:
                        _authenticationController.errors['loginUsername'] != null
                            ? Colors.red
                            : Colors.white,
                  ),
                  counterStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _authenticationController.errors['loginUsername'] != null
                              ? Colors
                                  .red // If there's an error, set border to red
                              : Colors.white, // Otherwise, keep it white
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _authenticationController.errors['loginUsername'] != null
                              ? Colors
                                  .red // If there's an error, set border to red
                              : Colors.white, // Otherwise, keep it white
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 10),

            Obx(() {
              return TextField(
                maxLength: 20,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                controller: loginPasswordController,

                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  labelStyle: TextStyle(color: Colors.white),
                  helperText:
                      _authenticationController.errors['loginPassword'] ??
                      _authenticationController.errors['loginPassword'],
                  helperStyle: TextStyle(
                    color:
                        _authenticationController.errors['loginPassword'] != null
                            ? Colors.red
                            : Colors.white,
                  ),
                  counterStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _authenticationController.errors['loginPassword'] != null
                              ? Colors
                                  .red // If there's an error, set border to red
                              : Colors.white, // Otherwise, keep it white
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _authenticationController.errors['loginPassword'] != null
                              ? Colors
                                  .red // If there's an error, set border to red
                              : Colors.white, // Otherwise, keep it white
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPassword()),
                  );
                },
                child: const Text(
                  "Şifreni mi unuttun?",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 90,
                  vertical: 15,
                ),
              ),

              onPressed: loginUser,
              child: Text('Giriş Yap', style: TextStyle(fontSize: 15)),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Hesabın mı yok?",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: const Text("Kayıt Ol" ,
                    style: TextStyle(color: Colors.blue),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
