import 'package:agapp/controllers/authentication.dart';
import 'package:agapp/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();
  final AuthenticationController _authenticationController = Get.put(
    AuthenticationController(),
  );
  bool _obscurePassword = true; // For toggling password visibility

  // Functions

  void loginUser() async {
    await _authenticationController.login(
      username: userNameController.text.trim(),
      password: passwordController.text.trim(),
      context: context, // Pass context for navigation
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text('AgApp'),
        centerTitle: true,

        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
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
                controller: userNameController,

                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                   helperText:
                      _authenticationController.errors['username'] ??
                      _authenticationController.errors['username'],
                  helperStyle: TextStyle(
                    color:
                        _authenticationController.errors['username'] != null
                            ? Colors.red
                            : Colors.white,
                  ),
                  counterStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _authenticationController.errors['username'] != null
                              ? Colors.red // If there's an error, set border to red
                              : Colors.white, // Otherwise, keep it white
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _authenticationController.errors['username'] != null
                              ? Colors.red // If there's an error, set border to red
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
                controller: passwordController,

                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  helperText:
                      _authenticationController.errors['password'] ??
                      _authenticationController.errors['password'],
                  helperStyle: TextStyle(
                    color:
                        _authenticationController.errors['password'] != null
                            ? Colors.red
                            : Colors.white,
                  ),
                  counterStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _authenticationController.errors['password'] != null
                              ? Colors.red // If there's an error, set border to red
                              : Colors.white, // Otherwise, keep it white
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _authenticationController.errors['password'] != null
                              ? Colors.red // If there's an error, set border to red
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
            SizedBox(height: 20),
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
              child: Text('Login', style: TextStyle(fontSize: 15)),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Not a user yet?",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: const Text("Register"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
