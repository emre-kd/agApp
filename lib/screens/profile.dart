// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers
import 'dart:convert';

import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/post.dart';
import 'package:agapp/screens/update-profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../constant.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  String errorMessage = '';
  Map<String, String> errors = {};
  bool isUpdating = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _createdAtController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _userNameController = TextEditingController();
    _emailController = TextEditingController();
    _createdAtController = TextEditingController();
    _passwordController = TextEditingController();
    fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _createdAtController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() {
        errorMessage = 'No authentication token found';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(userDetailsURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          // Handle case where response is a list
          if (decodedResponse is List<dynamic> && decodedResponse.isNotEmpty) {
            userData = decodedResponse[0] as Map<String, dynamic>;
          } else if (decodedResponse is Map<String, dynamic>) {
            userData = decodedResponse;
          } else {
            userData = {};
            errorMessage = 'Unexpected response format';
          }
          _nameController.text = userData['name']?.toString() ?? '';
          _userNameController.text = userData['username']?.toString() ?? '';
          _emailController.text = userData['email']?.toString() ?? '';
          _createdAtController.text = userData['created_at']?.toString() ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load user data: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  final List<Map<String, String>> posts = [
    {
      'profileImage': '',
      'name': 'John Doe 2',
      'username': '@johndoe',
      'timeAgo': '2h ago',
      'content': 'Lorem ipsum dolor sit amet.',
      'postImage': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    String formatCreatedAt(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        final formatter = DateFormat('dd MM yyyy');
        return 'Joined ${formatter.format(date)}';
      } catch (e) {
        return 'Joined Unknown';
      }
    }

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          backgroundColor: Colors.black,
          body: RefreshIndicator(
            onRefresh:
                fetchUserData, // Trigger fetchUserData on pull-to-refresh
            color: Colors.white, // Refresh indicator color
            backgroundColor: Colors.black.withOpacity(0.8), // Background color
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.black,
                  expandedHeight: 60,
                  floating: false,
                  pinned: true,
                  leading: Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      top: 7,
                      bottom: 7,
                    ),
                    child: SizedBox(
                      child: FloatingActionButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateProfile(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 1),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 5.0,
                          ),
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[300],
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    userData['coverImage'] != null
                                        ? NetworkImage(
                                          '$baseNormalURL/${userData['coverImage']}',
                                        )
                                        : const AssetImage(
                                              'assets/default-cover.png',
                                            )
                                            as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -75,
                        left: 20,
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            child: Ink(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                image:
                                    userData['image'] != null
                                        ? DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            '$baseNormalURL/${userData['image']}',
                                          ),
                                        )
                                        : null, // no image if null
                                color:
                                    Colors
                                        .grey[300], // light background behind the icon
                              ),
                              child:
                                  userData['image'] == null
                                      ? const Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white70,
                                        ),
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 90),
                        Row(
                          children: [
                            Text(
                              _nameController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '@${_userNameController.text}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatCreatedAt(_createdAtController.text),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Text(
                              '77 Follows',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '9 Takipçi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = posts[index];
                    return Post(
                      key: ValueKey(post['id'] ?? index), // Ensure unique key
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
          ),
        );
  }
}
