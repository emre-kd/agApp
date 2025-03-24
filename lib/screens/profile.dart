// ignore_for_file: deprecated_member_use

import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/post.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final List<Map<String, String>> posts = [
    {
      'profileImage': '',
      'name': 'John Doe',
      'username': '@johndoe',
      'timeAgo': '2h ago',
      'content': 'Lorem ipsum dolor sit amet.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe',
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
      body: CustomScrollView(
        slivers: [
          // AppBar with back button and profile edit button
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 200.0, // Height for the background image
            floating: false,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 7, bottom: 7),
              child: SizedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                      (route) => false,
                    );
                  },
                  backgroundColor: Colors.black.withOpacity(0.2),
                  elevation: 0,
                  highlightElevation: 0,
                  hoverElevation: 0,
                  focusElevation: 0,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1),
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 5.0,
                    ),
                  ),
                  child: const Text(
                    'Change Profile',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  FlexibleSpaceBar(
                    background: Image.asset(
                      'assets/profile_images/', // Replace with your image URL
                      fit:
                          BoxFit
                              .cover, // Ensure the image covers the entire space
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/default-cover.png', // Fallback to default cover image
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color:
                                  Colors
                                      .grey[800], 
                              child: const Center(
                                child: Text(
                                  'Failed to load default image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Profile picture overlay
                  Positioned(
                    left: 20,

                    bottom: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            Colors.grey, // Placeholder for profile image
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Profile details section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10), // Space for the profile picture
                  // Name and verified badge
                  Row(
                    children: const [
                      Text(
                        'EMRE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      /* SizedBox(width: 5),
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 20,
                      ), */
                    ],
                  ),
                  const Text(
                    '@bocukurtwitter',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 10),
                  // Joined date
                  const Text(
                    'Temmuz 2021 tarihinde katıldı',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  // Follower/Following counts
                  Row(
                    children: const [
                      Text(
                        '77 Follows',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(width: 20),
                      Text(
                        '9 Takipçi',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Posts list
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = posts[index];
              return Post(
                profileImage: post['profileImage']!,
                name: post['name']!,
                username: post['username']!,
                timeAgo: post['timeAgo']!,
                content: post['content']!,
                postImage: post['postImage']!,
              );
            }, childCount: posts.length),
          ),
        ],
      ),
    );
  }
}
