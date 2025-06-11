import 'package:agapp/screens/layouts/appbar.dart';
import 'package:agapp/screens/layouts/add_post.dart';

import 'package:agapp/screens/post.dart';
import 'package:agapp/screens/profile.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isFabVisible = true;

  final List<Map<String, String>> posts = [
    {
      'profileImage': '',
      'name': 'John Doe 2',
      'username': '@johndoe',
      'timeAgo': '2h ago',
      'content': 'Lorem ipsum dolor sit amet.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe 2',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe 2',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe 2',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe 2',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe 2',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe 2',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe 2',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
  ];
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
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
          child: ListView.builder(
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
          ),
        ),
      ),
    floatingActionButton: _isFabVisible
    ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => AddPost(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween(
                    begin: Offset(0, 1), // from bottom to top
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
                        onPressed: () {},
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
