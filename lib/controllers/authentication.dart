// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:agapp/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthenticationController extends GetxController {
  final isLoading = false.obs;
  final errors = <String, String>{}.obs; // Store errors here

  Future register({
    required String username,
    required String email,
    required String password,
    required String password_confirmation,
    required BuildContext context, // Pass BuildContext for navigation

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
        debugPrint("Error: ${response.statusCode} - $responseData");
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
