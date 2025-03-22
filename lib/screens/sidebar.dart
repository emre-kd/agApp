import 'package:agapp/controllers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidebarx/sidebarx.dart';

class ExampleSidebarX extends StatelessWidget {
  ExampleSidebarX({Key? key, required SidebarXController controller})
    : _controller = controller,
      super(key: key);

  final SidebarXController _controller;
  final AuthenticationController _authenticationController = Get.put(
    AuthenticationController(),
  );

  @override
  Widget build(BuildContext context) {
    final AuthenticationController authController =
        Get.find(); // Debugging - print the current user data

    authController.getUserDetails();

    return SidebarX(
      controller: _controller,

      theme: SidebarXTheme(
        textStyle: GoogleFonts.tektur(color: Colors.white, fontSize: 16),
        selectedTextStyle: GoogleFonts.tektur(
          color: Colors.white,
          fontSize: 16,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemDecoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        ),

        iconTheme: IconThemeData(color: Colors.white),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
        decoration: BoxDecoration(color: Colors.black),
      ),
      extendedTheme: const SidebarXTheme(
        width: 350,
        decoration: BoxDecoration(color: Colors.black),
      ),

      headerDivider: Padding(
        padding: const EdgeInsets.all(19.0),
        child: Column(
          children: [
            SizedBox(height: 100),
            // CircleAvatar for the user's image
            Obx(() {
              return CircleAvatar(
                radius: 50, // Adjust the size of the image
                backgroundImage:
                    authController.user.value.image != null
                        ? NetworkImage(
                          authController.user.value.image!,
                        ) // Network image if available
                        : AssetImage('assets/logo-dark.png')
                            as ImageProvider, // Default asset image if not available
              );
            }),
            SizedBox(height: 10),
            // Displaying the user's name
            Obx(() {
              return Text(
                authController.user.value.name ??
                    'Name2', // Fallback if name is null
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            SizedBox(height: 5),
            // Displaying the username
            Obx(() {
              return Text(
                authController.user.value.username ??
                    'Username', // Fallback if username is null
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            SizedBox(height: 5),
            // Displaying the user's email
            Obx(() {
              return Text(
                authController.user.value.email ??
                    'user@example.com', // Fallback if email is null
                style: TextStyle(color: Colors.white, fontSize: 14),
              );
            }),
            SizedBox(height: 20),
            Divider(color: Colors.white, thickness: 0.5),
          ],
        ),
      ),

      items: [
        const SidebarXItem(icon: Icons.home, label: 'Home'),
        const SidebarXItem(icon: Icons.person, label: 'Profile'),
        const SidebarXItem(icon: Icons.settings, label: 'Settings'),
        SidebarXItem(
          icon: Icons.logout,
          label: 'Logout',
          onTap: () => _authenticationController.logout(context),
        ),
      ],
    );
  }
}