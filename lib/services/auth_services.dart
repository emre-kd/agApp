// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:agapp/models/api_response.dart';
import 'package:agapp/models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {

// Register
Future<ApiResponse> registerUser(String name, String email, String password, String password_confirmation) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse(registerURL),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
    
    // Debugging: Check if the data is empty
      print('Name: ${name}');
      print('Email: ${email}');
      print('Password: ${password}');
      print('Password Confirmation: ${password_confirmation}');

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}
}
