
import 'package:flutter/material.dart';

const baseURL = 'http://192.168.1.102:8000/api';
const loginURL = '$baseURL/login';
const registerURL = '$baseURL/register';
const logoutURL = '$baseURL/logout';
const userURL = '$baseURL/user';
const postsURL = '$baseURL/posts';
const commentsURL = '$baseURL/comments';

const Map<String, String> headers  = {"Content-Type": "application/json"};

errorSnackBar (BuildContext context, String text) {

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Text(text),
    duration: const Duration(seconds: 1),
  ));
}