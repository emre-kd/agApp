// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:agapp/constant.dart';
import 'package:agapp/models/user.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/login.dart';
import 'package:agapp/screens/verification_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationController extends GetxController {
  final isLoading = false.obs;
  final errors = <String, String>{}.obs;
  var user = Rx<User>(User());
  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        var response = await http.get(
          Uri.parse(userDetailsURL),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        print("Token: $token");

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

  Future<bool> updateUser({
    required String name,
    required String email,
    required String username,
    required String password,
    File? profileImage,
    File? coverImage,
    required String token,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      errors.clear();

      // Create a multipart request instead of JSON for handling file uploads
      var request = http.MultipartRequest('POST', Uri.parse(updateUserURL));
      request.fields['_method'] = 'PUT';

      // Set headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['name'] = name;
      request.fields['username'] = username;
      request.fields['email'] = email;
      if (password.isNotEmpty) {
        request.fields['password'] = password;
      }

      // Add file fields if they exist
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            profileImage.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }
      if (coverImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'cover_image',
            coverImage.path,
            filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Color.fromARGB(255, 0, 145, 230),
          ),
        );
        return true;
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unauthorized. Please login again."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else if (response.statusCode == 422) {
        Map<String, dynamic> errorMessages = responseData['errors'];
        errorMessages.forEach((key, value) {
          errors[key] = value[0];
        });
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server error. Please try again later."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception in updateUser: $e');
      debugPrint('🔍 StackTrace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong. Check your connection."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    
    required String password,
    required String password_confirmation,
    required BuildContext context,
    String? communityCode,
    String? communityName,
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

      if (communityCode != null && communityCode.isNotEmpty) {
        data['community_code'] = communityCode;
      }
      if (communityName != null && communityName.isNotEmpty) {
        data['community_name'] = communityName;
      }

      var response = await http.post(
        Uri.parse(registerURL),
        headers: {'Accept': 'application/json'},
        body: data,
      );

      var responseData = json.decode(response.body);

      print(response.body);

      if (response.statusCode == 200 && responseData['requires_verification'] == true) {
        // Navigate to verification screen
              // 🔥 Buraya FCM token alma ve backend'e gönderme ekliyoruz

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(email: email, username: username),
          ),
        );
      } else if (response.statusCode == 422) {
        Map<String, dynamic> errorMessages = responseData['errors'];
        errorMessages.forEach((key, value) {
          errors[key] = value[0];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please check your connection."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyRegistration({
    required String code,
    required String email,
    required String username,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      
      var response = await http.post(
        Uri.parse('$baseURL/verify-registration'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'code': code,
          'email': email,
          'username': email,
        }),
      );

      var responseData = json.decode(response.body);
      print(response.body);

      if (response.statusCode == 201) {
        // Success case
        String token = responseData['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await sendFcmTokenToBackend(fcmToken);
        }
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (route) => false,
        );
      } else {
        // Error case
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Doğrulama başarısız oldu"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Network error. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationCode(String email, BuildContext context, String loginUsername) async {
    try {
      isLoading.value = true;
      
      var response = await http.post(
        Uri.parse('$baseURL/resend-verification'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'loginUsername': loginUsername},
      );

      var responseData = json.decode(response.body);
      print(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Doğrulama kodu yeniden gönderildi"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Kod yeniden gönderilemedi"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Doğrulama kodunu yeniden gönderme başarısız oldu"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future login({
    required String loginUsername,
    required String loginPassword,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      errors.clear();

      var data = {'loginUsername': loginUsername, 'loginPassword': loginPassword};
      var response = await http.post(
        Uri.parse(loginURL),
        headers: {'Accept': 'application/json'},
        body: data,
      );
      var responseData = json.decode(response.body);

          print(response.body);
      if (response.statusCode == 200) {
        debugPrint("Login Successful: $responseData");

        String token = responseData['token']; // API'dan gelen token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Kullanıcı detaylarını al
        await getUserDetails();

            String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await sendFcmTokenToBackend(fcmToken); // Ama hangi kullanıcı bu belli değil!
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Geçersiz bilgiler. Lütfen tekrar deneyin."),
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
            content: Text("Sunucu hatası. Lütfen daha sonra tekrar deneyin."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bir şeyler ters gitti. Lütfen bağlantınızı kontrol edin."),
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

      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 401) {
        debugPrint("Logout Successful");
        await prefs.remove('token');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false,
        );
      } else {
        debugPrint("Error: ${response.statusCode} - $responseData");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Çıkış yapılamadı. Tekrar deneyin."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bir şeyler ters gitti. Bağlantınızı kontrol edin."),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Logout Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestPasswordReset(String email, BuildContext context) async {
    try {
      isLoading.value = true;
      errors.clear(); // Clear previous errors

      final response = await http.post(
        Uri.parse('$baseURL/forgot-password'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print(response.body);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        Map<String, dynamic> errorMessages = responseData['errors'];
        errorMessages.forEach((key, value) {
          errors[key] = value[0]; // Update errors map with first error message
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors['email'] ?? 'E-posta gönderilemedi. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta gönderilemedi. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      print('Error requesting password reset: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ağ hatası. Lütfen bağlantınızı kontrol edin.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> verifyResetCode(String email, String code, BuildContext context) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('$baseURL/verify-reset-code'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      print(response.body);

      if (response.statusCode == 200) {
        
        return jsonDecode(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doğrulama kodu geçersiz.'),
          backgroundColor: Colors.red,
        ),
      );
        return null;
      }
    } catch (e) {
      print('Error verifying code: $e');
      Get.snackbar('Hata', 'Ağ hatası. Lütfen bağlantınızı kontrol edin.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resendResetCode(String email, BuildContext context) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('$baseURL/resend-reset-code'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Doğrulama kodu tekrar gönderildi!"),
            backgroundColor: Color.fromARGB(255, 0, 145, 230), // Match your success color
          ),
        );
        return true;
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        Map<String, dynamic> errorMessages = responseData['errors'];
        errorMessages.forEach((key, value) {
          errors[key] = value[0]; // Update errors map with first error message
        });
        Get.snackbar(
          'Hata',
          errors['email'] ?? 'Kodu tekrar gönderme başarısız.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'Hata',
          responseData['message'] ?? 'Kodu tekrar gönderme başarısız.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error resending reset code: $e');
      Get.snackbar(
        'Hata',
        'Ağ hatası. Lütfen bağlantınızı kontrol edin.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword, String resetToken, BuildContext context) async {
    try {
      isLoading.value = true;
      errors.clear(); // Clear previous errors

      final response = await http.post(
        Uri.parse('$baseURL/reset-password'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
          'newPassword_confirmation': newPassword,
          'reset_token': resetToken,
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Şifre başarıyla sıfırlandı!"),
            backgroundColor: Color.fromARGB(255, 0, 145, 230), // Match success color
          ),
        );
        return true;
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        Map<String, dynamic> errorMessages = responseData['errors'];
        errorMessages.forEach((key, value) {
          errors[key] = value[0]; // Update errors map with first error message
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errors['newPassword'] ??
                  errors['newPassword_confirmation'] ??
                  errors['email'] ??
                  errors['reset_token'] ??
                  'Şifre sıfırlama başarısız.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Şifre sıfırlama başarısız.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      print('Error resetting password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ağ hatası. Lütfen bağlantınızı kontrol edin.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  }


  Future<void> sendFcmTokenToBackend(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    if (authToken == null) return;

    try {
      final response = await http.post(
        Uri.parse(firebaseUpdateFcmURL),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("FCM token backend'e başarıyla gönderildi.");
      } else {
        debugPrint("FCM token gönderilirken hata: ${response.body}");
      }
    } catch (e) {
      debugPrint("FCM gönderme hatası: $e");
    }
  }

