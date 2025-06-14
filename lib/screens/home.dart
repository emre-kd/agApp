import 'dart:convert';

import 'package:agapp/constant.dart';
import 'package:agapp/screens/post.dart' show PostWidget;
import 'package:agapp/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

import 'package:agapp/models/post.dart';
import 'package:agapp/screens/layouts/appbar.dart';
import 'package:agapp/screens/layouts/add_post.dart';
import 'package:agapp/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isFabVisible = true;
  bool _isLoading = true;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const url = fetchPostURL;
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postJson = data['posts'];

        setState(() {
          posts = postJson.map((json) => Post.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Fetch error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Appbar(),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse &&
              _isFabVisible) {
            setState(() => _isFabVisible = false);
          } else if (notification.direction == ScrollDirection.forward &&
              !_isFabVisible) {
            setState(() => _isFabVisible = true);
          }
          return true;
        },
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.black.withOpacity(0.8),
          onRefresh: fetchPosts,
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : posts.isEmpty
                  ? const Center(
                    child: Text(
                      'Topluluğunuzda hiç gönderi yok',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                  : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post =
                          posts[index]; // Assuming posts is List<post_model.Post>
                      return PostWidget(
                        post: post, // Pass the entire Post model
                        parentScreen: 'home'
                      );
                    },
                  ),
        ),
      ),
      floatingActionButton:
          _isFabVisible
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => AddPost(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween(
                            begin: Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, color: Colors.white, size: 25),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar:
          _isFabVisible
              ? Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => Home()),
                          );
                        },
                        icon: Icon(Icons.home, color: Colors.white),
                      ),
                      SizedBox(width: 40),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => Search()),
                          );
                        },
                        icon: Icon(Icons.search_rounded, color: Colors.white),
                      ),
                      SizedBox(width: 40),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.mail_outline, color: Colors.white),
                      ),
                      SizedBox(width: 40),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Profile()),
                          );
                        },
                        icon: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }
}
