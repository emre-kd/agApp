// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:agapp/controllers/authentication.dart';
import 'package:agapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _communityChoice = 'join'; // 'join' or 'create'
  final TextEditingController communityNameController = TextEditingController();
  final TextEditingController communityDescController = TextEditingController();
  final TextEditingController communityCodeController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();
  final AuthenticationController _authenticationController = Get.put(
    AuthenticationController(),
  );

  bool _obscurePassword = true;
  bool isLoading = false;

  void registerUser() async {
   if (_communityChoice == 'create') {
    // Yeni topluluk oluşturulacak
    await _authenticationController.register(
      username: userNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      password_confirmation: passwordConfirmationController.text.trim(),
      context: context,
    );
  } else {
    // Var olan topluluğa katılım
    await _authenticationController.register(
      username: userNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      password_confirmation: passwordConfirmationController.text.trim(),
      context: context,
    );
  }
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
      body: SingleChildScrollView(
        // Added SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
          child: Column(
            children: [
              Image.asset("assets/logo.png", height: 120),
              const SizedBox(height: 20),
              // Email field
              Obx(
                () => TextField(
                  maxLength: 40,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-Posta',
                    labelStyle: const TextStyle(color: Colors.white),
                    helperText:
                        _authenticationController.errors['email'] ??
                        _authenticationController.errors['email'],
                    helperStyle: TextStyle(
                      color:
                          _authenticationController.errors['email'] != null
                              ? Colors.red
                              : Colors.white,
                    ),
                    prefixIcon: const Icon(Icons.mail, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _authenticationController.errors['email'] != null
                                ? Colors.red
                                : Colors.white,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _authenticationController.errors['email'] != null
                                ? Colors.red
                                : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              // Username field
              Obx(
                () => TextField(
                  maxLength: 20,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  controller: userNameController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
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
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _authenticationController.errors['username'] != null
                                ? Colors.red
                                : Colors.white,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _authenticationController.errors['username'] != null
                                ? Colors.red
                                : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 5),

                   // Community Selection
            Row(
              children: [
                Radio<String>(
                  value: 'join',
                  groupValue: _communityChoice,
                  onChanged:
                      (value) => setState(() => _communityChoice = value!),
                  activeColor: Colors.white,
                ),
                const Expanded(
                  child: Text(
                    "Var olan topluluğa katıl",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Radio<String>(
                  value: 'create',
                  groupValue: _communityChoice,
                  onChanged:
                      (value) => setState(() => _communityChoice = value!),
                  activeColor: Colors.white,
                ),
                const Expanded(
                  child: Text(
                    "Yeni topluluk oluştur",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Conditional Fields
            _communityChoice == 'join'
                ? Obx(
                  () => TextField(
                    maxLength: 5,
                    controller: communityCodeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Topluluk Kodu',
                      labelStyle: const TextStyle(color: Colors.white),
                      helperText:
                          _authenticationController.errors['community_code'],
                      helperStyle: TextStyle(
                        color:
                            _authenticationController
                                        .errors['community_code'] !=
                                    null
                                ? Colors.red
                                : Colors.white,
                      ),
                      prefixIcon: const Icon(Icons.code, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                )
                : Column(
                  children: [
                    TextField(
                      maxLength: 20,
                      controller: communityNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Topluluk Adı',
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.group, color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
              
                
                  ],
                ),

            const SizedBox(height: 10),
 
              Obx(
                () => TextField(
                  maxLength: 25,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _authenticationController.errors['password'] != null
                                ? Colors.red
                                : Colors.white,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _authenticationController.errors['password'] != null
                                ? Colors.red
                                : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),

              
              // Password confirmation field
              Obx(
                () => TextField(
                  maxLength: 20,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  controller: passwordConfirmationController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _authenticationController.errors['password'] != null
                                ? Colors.red
                                : Colors.white,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _authenticationController.errors['password'] != null
                                ? Colors.red
                                : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Obx(() {
                return _authenticationController.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 90,
                          vertical: 15,
                        ),
                      ),
                      onPressed: registerUser,
                      child:
                          isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                'Kayıt Ol',
                                style: TextStyle(fontSize: 15),
                              ),
                    );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Zaten üye misiniz ?",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: const Text("Giriş"),
                  ),
                ],
              ),
              SizedBox(height: 20), // Add some padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
