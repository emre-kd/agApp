// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:agapp/models/user.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationController extends GetxController {
  final isLoading = false.obs;
  final errors = <String, String>{}.obs;
  var user = Rx<User>(User()); // Store user data

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        var response = await http.get(
          Uri.parse(userDetailsURL),
          headers: {'Authorization': 'Bearer $token'},
        );

        print("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          user.value = User.fromJson(data); // Update user with API data
          print("User data: ${user.value}");
        } else {
          print("Error: ${response.body}");
        }
      } catch (e) {
        print("Error fetching user details: $e");
      }
    }
  }

  Future register({
    required String username,
    required String email,
    required String password,
    required String password_confirmation,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      errors.clear();

      var data = {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password_confirmation,
      };
      var response = await http.post(
        Uri.parse(registerURL),
        headers: {'Accept': 'application/json'},
        body: data,
      );

      var responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        debugPrint("Registration Successful: $responseData");

        String token = responseData['token']; // Ensure your API returns a token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        await getUserDetails();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()), // Navigate to Home
          (route) => false, // Remove all previous routes
        );
      } else if (response.statusCode == 422) {
        // Laravel validation error
        Map<String, dynamic> errorMessages = responseData['errors'];
        errorMessages.forEach((key, value) {
          errors[key] = value[0]; // Store only the first error for each field
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server error. Please try again later."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong. Please check your connection."),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Exception: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future login({
    required String username,
    required String password,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      errors.clear();

      var data = {'username': username, 'password': password};
      var response = await http.post(
        Uri.parse(loginURL),
        headers: {'Accept': 'application/json'},
        body: data,
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        debugPrint("Login Successful: $responseData");

        String token = responseData['token']; // Ensure your API returns a token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        await getUserDetails();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (route) => false,
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid credentials. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.statusCode == 422) {
        Map<String, dynamic> errorMessages = responseData['errors'];
        errorMessages.forEach((key, value) {
          errors[key] = value[0];
        });
      } else {
        debugPrint("Error: ${response.statusCode} - $responseData");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server error. Please try again later."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong. Please check your connection."),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Exception: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      isLoading.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var response = await http.post(
        Uri.parse(logoutURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 401) {
        debugPrint("Logout Successful");
        await prefs.remove('token');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
          (route) => false,
        );
      } else {
        debugPrint("Error: ${response.statusCode} - $responseData");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to logout. Try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Check your connection."),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Logout Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
