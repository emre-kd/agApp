import 'package:agapp/screens/register.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true; // For toggling password visibility

  // Functions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
    
        title: Text('AgApp', ),
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

            TextField(
              maxLength: 20,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),

              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
                counterStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.person, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 10),

            TextField(
              maxLength: 20,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),

              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                counterStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
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
                border: const OutlineInputBorder(),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 90,
                  vertical: 15,
                ),
              ),
              

              onPressed: () {},
              child:  Text('Login', style: TextStyle(
                fontSize: 15,
           
              ),) 
              ,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Not a user yet?",  style: TextStyle(color: Colors.white) , ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: const Text("Register", ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
