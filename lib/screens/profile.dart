// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_field
import 'dart:convert';

import 'package:agapp/models/post.dart';
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
  List<Post> posts = [];
  bool isLoading = true;
  bool _isLoadingMore = false; // Track loading more posts
  String errorMessage = '';
  Map<String, String> errors = {};
  bool isUpdating = false;
  int? currentUserId;
  int _page = 1; // Track current page
  final int _limit = 5; // Number of posts per page
  bool _hasMore = true; // Track if more posts are available
  final ScrollController _scrollController = ScrollController();

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
    fetchUserPosts();

    // Add listener to scroll controller for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        fetchMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _createdAtController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
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
          currentUserId = userData['id']?.toInt();
          isLoading = false;
        });
        // Save user ID to SharedPreferences
        if (currentUserId != null) {
          await prefs.setInt('id', currentUserId!);
        }
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

  Future<void> fetchUserPosts() async {
    setState(() {
      isLoading = true;
      _page = 1; // Reset to first page for refresh
      _hasMore = true; // Reset hasMore
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$fetchUserPostURL?page=$_page&limit=$_limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postJson = data['posts'];

        setState(() {
          posts = postJson.map((json) => Post.fromJson(json)).toList();
          isLoading = false;
          _hasMore =
              postJson.length == _limit; // Check if more posts are available
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Fetch error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate 1-second delay
    await Future.delayed(const Duration(seconds: 1));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$fetchUserPostURL?page=${_page + 1}&limit=$_limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postJson = data['posts'];

        setState(() {
          _page++;
          posts.addAll(postJson.map((json) => Post.fromJson(json)).toList());
          _isLoadingMore = false;
          _hasMore = postJson.length == _limit;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      print('Fetch error: $e');
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatCreatedAt(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        final formatter = DateFormat('dd MM yyyy');
        return '${formatter.format(date)} tarihinde katıldı';
      } catch (e) {
        return 'N/A';
      }
    }

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          backgroundColor: Colors.black,
          body: RefreshIndicator(
            onRefresh: () async {
              await fetchUserData();
              await fetchUserPosts(); // Refresh both user data and posts
            },
            color: Colors.white,
            backgroundColor: Colors.black.withOpacity(0.8),
            child: CustomScrollView(
              controller: _scrollController, // Attach ScrollController
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
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
                        onPressed: () {
                          Navigator.push(
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
                          'Profili Güncelle',
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
                                        : null,
                                color: Colors.grey[300],
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                posts.isEmpty
                    ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Gönderi yok',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == posts.length && _isLoadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                        final post = posts[index];
                        return PostWidget(
                          post: post,
                          parentScreen: 'profile',
                          currentUserId: currentUserId,
                        );
                      }, childCount: posts.length + (_isLoadingMore ? 1 : 0)),
                    ),
              ],
            ),
          ),
        );
  }
}
