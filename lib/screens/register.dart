// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:agapp/constant.dart';
import 'package:agapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  bool _obscurePassword = true;
  bool isLoading = false;

  // Laravel registration API URL

  // Register function to send data to Laravel API
  register() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    // Collect data from text fields
    var data = {
      'email': emailController.text,
      'username': userNameController.text,
      'password': passwordController.text,
      'password_confirmation': passwordConfirmationController.text,
    };

    // Send POST request to Laravel API
    try {
      final response = await http.post(
        Uri.parse(registerURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}'); // Print status code
      print(
        'Response body: ${response.body}',
      ); // Print response body for debugging

      if (response.statusCode == 201) {
        // Successful registration
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration successful!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ), // Replace with your login screen
        );
      } else {
        // Registration failed
        var errorResponse = json.decode(response.body);
        print('Error Response: $errorResponse'); // Print error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorResponse['message'] ?? 'Registration failed'),
          ),
        );
      }
    } catch (e) {
      // Handle errors (e.g., no internet connection)
      print('Error occurred: $e'); // Print error in the console
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
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
      body: Padding(
        padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
        child: Column(
          children: [
            Image.asset("assets/logo.png", height: 120),
            const SizedBox(height: 20),
            // Email field
            TextField(
              maxLength: 40,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.mail, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Username field
            TextField(
              maxLength: 20,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              controller: userNameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.person, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Password field
            TextField(
              maxLength: 20,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Password confirmation field
            TextField(
              maxLength: 20,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              controller: passwordConfirmationController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password Confirmation',
                labelStyle: TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Register button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 90,
                  vertical: 15,
                ),
              ),
              onPressed: isLoading ? null : () => register(),
              child:
                  isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Register', style: TextStyle(fontSize: 15)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already user ?",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
