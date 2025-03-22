// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:agapp/screens/post.dart';
import 'package:agapp/screens/profile.dart';
import 'package:agapp/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:agapp/screens/sidebar.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SidebarX Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: GoogleFonts.tekturTextTheme(),
      ),
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            drawerScrimColor: Colors.transparent,
            appBar:
                isSmallScreen
                    ? AppBar(
                      backgroundColor: Colors.black,
                      toolbarHeight: 50, // Set height to 400
                      leading: IconButton(
                        onPressed: () {
                          if (!Platform.isAndroid && !Platform.isIOS) {
                            _controller.setExtended(true);
                          }
                          _key.currentState?.openDrawer();
                        },
                        icon: Icon(
                          Icons.circle,
                          color: Colors.white,
                        ), // Left-sided circle icon
                      ), // Left-sided circle icon
                      title: Center(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 50,
                        ), // Center image
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
                    )
                    : null,
            drawer: ExampleSidebarX(controller: _controller),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller),
                Expanded(child: _ScreensExample(controller: _controller)),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.blue,
              child: Icon(Icons.add, color: Colors.white, size: 25),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

            bottomNavigationBar: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ), // Top border
                ),
              ),
              child: BottomAppBar(
                shape: CircularNotchedRectangle(),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.home, color: Colors.white),
                    ),
                    SizedBox(width: 40),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search_rounded, color: Colors.white),
                    ),
                    SizedBox(width: 40),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.people, color: Colors.white),
                    ),
                    SizedBox(width: 40),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.email_outlined, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScreensExample extends StatelessWidget {
  _ScreensExample({Key? key, required this.controller}) : super(key: key);

  final SidebarXController controller;
  final List<Map<String, String>> posts = [
    {
      'profileImage': 'https://example.com/profile1.jpg',
      'name': 'John Doe',
      'username': '@johndoe',
      'timeAgo': '2h ago',
      'content': 'Lorem ipsum dolor sit amet.',
      'postImage': 'https://example.com/post1.jpg',
    },
    {
      'profileImage': 'https://example.com/profile2.jpg',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': 'https://example.com/post2.jpg',
    },

    {
      'profileImage': 'https://example.com/profile2.jpg',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': 'https://example.com/post2.jpg',
    },
       {
      'profileImage': 'https://example.com/profile2.jpg',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': 'https://example.com/post2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.selectedIndex) {
          case 0:
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Post(
                  profileImage: post['profileImage']!,
                  name: post['name']!,
                  username: post['username']!,
                  timeAgo: post['timeAgo']!,
                  content: post['content']!,
                  postImage: post['postImage']!,
                );
              },
            );

          case 1:
            return const Profile();
          case 2:
            return const Settings();

          default:
            return Text('deneme');
        }
      },
    );
  }
}

const primaryColor = Colors.black;
const canvasColor = Colors.black;
const scaffoldBackgroundColor = Colors.black;
const accentCanvasColor = Color.fromARGB(255, 0, 0, 0);

final actionColor = const Color.fromARGB(255, 0, 0, 0).withOpacity(1);
final divider = Divider(color: const Color.fromARGB(31, 0, 0, 0), height: 1);
