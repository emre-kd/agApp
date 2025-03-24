import 'package:agapp/screens/layouts/appbar.dart';
import 'package:agapp/screens/post.dart';
import 'package:agapp/screens/profile.dart';

import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Appbar(),
      body: ListView.builder(
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
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ), 
                    (route) => false, 
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
                icon: Icon(Icons.person_add , color: Colors.white),
              ),
                   SizedBox(width: 40),
               IconButton(
                onPressed: () {
                    Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(),
                    ), 
                    (route) => false, 
                  );
                },
                icon: Icon(Icons.person , color: Colors.white),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
