import 'package:agapp/controllers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
   final AuthenticationController _authenticationController = Get.put(
    AuthenticationController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      ElevatedButton(
  onPressed: () => _authenticationController.logout(context),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
  child: Text("Logout"),
),
      
      appBar: AppBar(
        
        title: Text('Home'),
        
        
        
      ),


      
    );
    
  }
}