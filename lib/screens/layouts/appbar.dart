import 'package:agapp/controllers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget {
   const Appbar({super.key});

  @override
  Widget build(BuildContext context) {
       final AuthenticationController _authenticationController = Get.put( AuthenticationController(),);

    return AppBar(
      backgroundColor: Colors.black,
      toolbarHeight: 50, // Set height to 400
      leading: IconButton(
        onPressed: () {},
        icon: Icon(Icons.circle, color: Colors.white), // Left-sided circle icon
      ), // Left-sided circle icon
      title: Center(
        child: Image.asset('assets/logo.png', height: 40), // Center image
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: const Color.fromARGB(255, 158, 152, 152),
              
              context: context,
              isScrollControlled: true, // Allowing custom height
              builder: (BuildContext context) {
                return SizedBox(
                  
                  height: 60, // Set your custom height here
                  
                  child: Column(
                    
                    children: <Widget>[
                      ListTile(
                        
                        leading: Icon(Icons.arrow_back, color: Colors.black,),
                        title: Text('Logout' , style: TextStyle(color: Colors.black),),
                        onTap: () {
                         
                          _authenticationController.logout(context);
                        },
                      ),
                     
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
