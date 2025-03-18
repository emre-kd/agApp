import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:http/http.dart' as http;

class AuthService {

  static Future<http.Response> register(
      String username, String email, String password, String passwordConfirmation ) async {

        Map data = {
          "username" :  username,
          "email" :  email,
          "password" :  password,
          "passwordConfirmation" :  passwordConfirmation,

        };

        var body = json.encode(data);
        var url = Uri.parse(registerURL);

        http.Response response = await http.post(
          url,
          headers: headers,
          body: body,
        );

        print(response.body);
        return response;


   

  }
}
