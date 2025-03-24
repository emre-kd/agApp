import 'package:flutter/material.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget {
  const Appbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 50, // Set height to 400
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.circle,
            color: Colors.white,
          ), // Left-sided circle icon
        ), // Left-sided circle icon
        title: Center(
          child: Image.asset('assets/logo.png', height: 50), // Center image
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Action for the three-dot menu
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ), // Right-sided three-dot icon
          ),
        ],
      );
    
  }
    @override
  Size get preferredSize => Size.fromHeight(50);
}