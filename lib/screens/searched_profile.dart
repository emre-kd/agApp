// ignore_for_file: deprecated_member_use, avoid_print
import 'dart:convert';
import 'package:agapp/models/post.dart';
import 'package:agapp/screens/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../constant.dart';

class SearchedProfile extends StatefulWidget {
  final int userId; // Required userId to fetch specific user data

  const SearchedProfile({super.key, required this.userId});

  @override
  _SearchedProfileState createState() => _SearchedProfileState();
}

class _SearchedProfileState extends State<SearchedProfile> {
  Map<String, dynamic> userData = {};
  List<Post> posts = [];
  bool isLoading = true;
  String errorMessage = '';

  // Controllers for user data display
  late TextEditingController _nameController;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _createdAtController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _userNameController = TextEditingController();
    _emailController = TextEditingController();
    _createdAtController = TextEditingController();
    fetchUserData();
    fetchUserPosts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _createdAtController.dispose();
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
      Uri.parse('$getSearchedUserDetailsURL/${widget.userId}'), // Fetch specific user
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('API Response: ${response.body}'); // Debug API response

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      setState(() {
        // Always extract the 'user' object from the response
        userData = decodedResponse['user'] ?? {};
        _nameController.text = userData['name']?.toString() ?? '';
        _userNameController.text = userData['username']?.toString() ?? '';
        _emailController.text = userData['email']?.toString() ?? '';
        _createdAtController.text = userData['created_at']?.toString() ?? '';
        isLoading = false;

        // Debug userData after assignment
        print('Username: ${userData['username']}');
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load user data: ${response.body}';
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Error fetching user data: $e';
      isLoading = false;
    });
  }
}

  Future<void> fetchUserPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() {
        errorMessage = 'No authentication token found';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$fetchUserPostURL/${widget.userId}/posts'), // Fetch user's posts
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postJson = data['posts'] ?? [];

        setState(() {
          posts = postJson.map((json) => Post.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error fetching posts: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching posts: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatCreatedAt(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        final formatter = DateFormat('dd MMM yyyy');
        return 'Joined ${formatter.format(date)}';
      } catch (e) {
        return 'Joined Unknown';
      }
    }

    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : Scaffold(
            backgroundColor: Colors.black,
            body: RefreshIndicator(
              onRefresh: () async {
                await fetchUserData();
                await fetchUserPosts();
              },
              color: Colors.white,
              backgroundColor: Colors.black.withOpacity(0.8),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.black,
                    expandedHeight: 60,
                    floating: false,
                    pinned: true,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 7, bottom: 7),
                      child: SizedBox(
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.pop(context); // Return to previous screen
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
                    actions: const [], // No "Update Profile" for other users
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
                                  image: userData['coverImage'] != null
                                      ? NetworkImage('$baseNormalURL/${userData['coverImage']}')
                                      : const AssetImage('assets/default-cover.png') as ImageProvider,
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
                                  border: Border.all(color: Colors.white, width: 4),
                                  image: userData['image'] != null
                                      ? DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage('$baseNormalURL/${userData['image']}'),
                                        )
                                      : null,
                                  color: Colors.grey[300],
                                ),
                                child: userData['image'] == null
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
                          Text(
                            _nameController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${_userNameController.text}',
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            formatCreatedAt(_createdAtController.text),
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                userData['follows']?.toString() ?? '0 Follows',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                userData['followers']?.toString() ?? '0 Takipçi',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Text(
                                errorMessage,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  posts.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No posts available',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = posts[index];
                              return PostWidget(
                                post: post,
                                parentScreen: 'SearchedProfile',
                              );
                            },
                            childCount: posts.length,
                          ),
                        ),
                ],
              ),
            ),
          );
  }
}