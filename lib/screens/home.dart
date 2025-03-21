// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:agapp/controllers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sidebarx/sidebarx.dart';

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
                Expanded(
                  child: Center(
                    child: _ScreensExample(controller: _controller),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.blue,
              child: Icon(Icons.add, color: Colors.white, size: 25,),

            ),
            floatingActionButtonLocation:
          
            FloatingActionButtonLocation.endFloat,

  
            bottomNavigationBar: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1), // Top border
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

        iconTheme: IconThemeData(color: Colors.white, size: 30),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
        decoration: BoxDecoration(color: Colors.black),
      ),
      extendedTheme: const SidebarXTheme(
        width: 350,
        decoration: BoxDecoration(color: Colors.black),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/logo.png'),
          ),
        );
      },
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

class _ScreensExample extends StatelessWidget {
  const _ScreensExample({Key? key, required this.controller}) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.selectedIndex) {
          case 0:
            return ListView.builder(
              itemBuilder:
                  (context, index) => Container(
                    height: 300,
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      boxShadow: const [BoxShadow()],
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Top Border Example"),
                    ),
                  ),
            );
          case 1:
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemBuilder:
                  (context, index) => Container(
                    height: 100,
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 10,
                      right: 10,
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).canvasColor,
                      boxShadow: const [BoxShadow()],
                    ),
                  ),
            );
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
