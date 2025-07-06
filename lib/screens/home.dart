// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:agapp/controllers/authentication.dart';
import 'package:agapp/screens/chat_list.dart';
import 'package:agapp/screens/community_details.dart';
import 'package:agapp/screens/leaderboard.dart';
import 'package:agapp/screens/post.dart' show PostWidget;
import 'package:agapp/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:agapp/models/post.dart';
import 'package:agapp/screens/layouts/add_post.dart';
import 'package:agapp/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthenticationController _authenticationController = Get.put(
    AuthenticationController(),
  );
  bool _isFabVisible = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Post> posts = [];
  List<Post> _pendingNewPosts = []; // Store new posts until user loads them
  int? currentUserId;
  String? communityName; // New state variable for community name
  int? communityId;
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
          communityName = data['community']?['name'] ?? 'Unknown Community';
          communityId = data['community']?['id'] ?? 'Unknown Community';

          print(communityName);
        });
      } else {
        print('Kullanıcı bilgisi alınamadı: ${response.statusCode}');
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
      appBar: AppBar(
        backgroundColor: Colors.black87, // Slightly lighter black for depth
        elevation: 8, // Slightly increased for better shadow definition
        shadowColor: Colors.white.withOpacity(
          0.1,
        ), // Softer shadow for elegance
        toolbarHeight: 60,

        automaticallyImplyLeading: false, // Prevent default back button
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain, // Ensure logo scales properly
              ),
            ),
            Text(
              communityName ?? 'Yükleniyor...', // Dynamic community name
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 28, // Larger icon for consistency
            ),
            tooltip: 'Daha fazla seçenek', // Accessibility improvement
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.grey[900],

                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      children: [
                        
                        ListTile(
                          leading: const Icon(
                            Icons.info_outline, // Icon for community details
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Topluluk Detayları',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16, // Readable text size
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommunityDetails(),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                _authenticationController.logout(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.red.withOpacity(
                                    0.1,
                                  ), // subtle red background
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.logout, color: Colors.red),
                                    SizedBox(width: 16),
                                    Text(
                                      'Çıkış Yap',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
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
                          'Topluluğunuzda hiç gönderi yok, ilk gönderiyi sen oluştur !',
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
                                padding: EdgeInsets.all(26.0),
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
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Search()),
                          );
                        },
                        icon: Icon(Icons.search_rounded, color: Colors.white),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Leaderboard()),
                          );
                        },
                        icon: Icon(Icons.leaderboard, color: Colors.white),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ChatList()),
                          );
                        },
                        icon: Icon(Icons.mail_outline, color: Colors.white),
                      ),
                      SizedBox(width: 20),
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
