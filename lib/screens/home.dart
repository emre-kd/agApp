// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
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
  bool _isLoadingMore = false;
  List<Post> posts = [];
  List<Post> _pendingNewPosts = []; // Store new posts until user loads them
  int? currentUserId;
  int _page = 1;
  final int _limit = 5;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchPosts();

    // Start polling every 15 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isLoading && !_isLoadingMore) {
        checkForNewPosts();
      }
    });

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
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(userDetailsURL),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        prefs.setInt('id', data['id']);
        setState(() {
          currentUserId = data['id'];
        });
      } else {
        print('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (_e) {
      print('Error fetching user info: $_e');
    }
  }

  Future<void> fetchPosts() async {
    setState(() {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
      _pendingNewPosts.clear(); // Clear pending posts on refresh
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$fetchPostURL?page=1&limit=$_limit'),
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
          _hasMore = postJson.length == _limit;
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

  Future<void> checkForNewPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$fetchPostURL?page=1&limit=$_limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> postJson = data['posts'];
        final newPosts = postJson.map((json) => Post.fromJson(json)).toList();

        // Filter out duplicates
        final existingPostIds = posts.map((p) => p.id).toSet();
        final uniqueNewPosts =
            newPosts
                .where((newPost) => !existingPostIds.contains(newPost.id))
                .toList();

        if (uniqueNewPosts.isNotEmpty && mounted) {
          setState(() {
            _pendingNewPosts = uniqueNewPosts;
          });
        }
      } else {
        print('Error checking new posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking new posts: $e');
    }
  }

  void loadNewPosts() {
    if (_pendingNewPosts.isEmpty) return;

    setState(() {
      posts.insertAll(0, _pendingNewPosts);
      _pendingNewPosts = [];
    });

    // Smoothly scroll to the top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> fetchMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$fetchPostURL?page=${_page + 1}&limit=$_limit'),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Appbar(),
      body: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
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
                        controller: _scrollController,
                        itemCount: posts.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == posts.length) {
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
                            parentScreen: 'home',
                            currentUserId: currentUserId,
                          );
                        },
                      ),
            ),
          ),
          // "New Posts" button
          if (_pendingNewPosts.isNotEmpty)
            Positioned(
              top: 16,
              left: MediaQuery.of(context).size.width / 2 - 80,
              child: ElevatedButton(
                onPressed: loadNewPosts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${_pendingNewPosts.length} yeni gönderi',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
