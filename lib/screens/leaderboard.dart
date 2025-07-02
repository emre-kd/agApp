// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_field
import 'dart:convert';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../constant.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  List<Post> mostLikedPosts = [];
  List<Post> mostCommentedPosts = [];
  bool isLoadingLiked = true;
  bool isLoadingCommented = true;
  bool _isLoadingMoreLiked = false;
  bool _isLoadingMoreCommented = false;
  String errorMessage = '';
  int _pageLiked = 1;
  int _pageCommented = 1;
  final int _limit = 5;
  bool _hasMoreLiked = true;
  bool _hasMoreCommented = true;
  final ScrollController _scrollControllerLiked = ScrollController();
  final ScrollController _scrollControllerCommented = ScrollController();
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _initialize();

    _scrollControllerLiked.addListener(() {
      if (_scrollControllerLiked.position.pixels >=
              _scrollControllerLiked.position.maxScrollExtent - 200 &&
          !_isLoadingMoreLiked &&
          _hasMoreLiked) {
        fetchMoreMostLikedPosts();
      }
    });

    _scrollControllerCommented.addListener(() {
      if (_scrollControllerCommented.position.pixels >=
              _scrollControllerCommented.position.maxScrollExtent - 200 &&
          !_isLoadingMoreCommented &&
          _hasMoreCommented) {
        fetchMoreMostCommentedPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollControllerLiked.dispose();
    _scrollControllerCommented.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('id');
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() {
        errorMessage = 'No authentication token found';
        isLoadingLiked = false;
        isLoadingCommented = false;
      });
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    await Future.wait([fetchMostLikedPosts(), fetchMostCommentedPosts()]);
  }

  Future<void> fetchMostLikedPosts() async {
    setState(() {
      isLoadingLiked = true;
      _pageLiked = 1;
      _hasMoreLiked = true;
      errorMessage = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() {
        errorMessage = 'No authentication token found';
        isLoadingLiked = false;
      });
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse('$fetchMostLikedPostsURL?page=$_pageLiked&limit=$_limit'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Most Liked Response: ${response.body}'); // Debug raw response

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> postJson;

        if (data['posts'] is Map<String, dynamic> &&
            data['posts']['data'] is List<dynamic>) {
          postJson = data['posts']['data'];
        } else if (data['posts'] is List<dynamic>) {
          postJson = data['posts'];
        } else {
          setState(() {
            errorMessage =
                'Invalid API response format: Expected posts or posts.data';
            isLoadingLiked = false;
          });
          return;
        }

        setState(() {
          mostLikedPosts = postJson.map((json) => Post.fromJson(json)).toList();
          isLoadingLiked = false;
          _hasMoreLiked = postJson.length == _limit;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load most liked posts: ${response.statusCode} - ${response.body}';
          isLoadingLiked = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching most liked posts: ${e.toString()}';
        isLoadingLiked = false;
      });
    }
  }

  Future<void> fetchMoreMostLikedPosts() async {
    if (_isLoadingMoreLiked || !_hasMoreLiked) return;

    setState(() {
      _isLoadingMoreLiked = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http
          .get(
            Uri.parse(
              '$fetchMostLikedPostsURL?page=${_pageLiked + 1}&limit=$_limit',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('More Most Liked Response: ${response.body}'); // Debug raw response

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> postJson;

        if (data['posts'] is Map<String, dynamic> &&
            data['posts']['data'] is List<dynamic>) {
          postJson = data['posts']['data'];
        } else if (data['posts'] is List<dynamic>) {
          postJson = data['posts'];
        } else {
          setState(() {
            _isLoadingMoreLiked = false;
          });
          return;
        }

        setState(() {
          _pageLiked++;
          mostLikedPosts.addAll(
            postJson.map((json) => Post.fromJson(json)).toList(),
          );
          _isLoadingMoreLiked = false;
          _hasMoreLiked = postJson.length == _limit;
        });
      } else {
        setState(() {
          _isLoadingMoreLiked = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMoreLiked = false;
      });
    }
  }

  Future<void> fetchMostCommentedPosts() async {
    setState(() {
      isLoadingCommented = true;
      _pageCommented = 1;
      _hasMoreCommented = true;
      errorMessage = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() {
        errorMessage = 'No authentication token found';
        isLoadingCommented = false;
      });
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse(
              '$fetchMostCommentedPostsURL?page=$_pageCommented&limit=$_limit',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Most Commented Response: ${response.body}'); // Debug raw response

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> postJson;

        if (data['posts'] is Map<String, dynamic> &&
            data['posts']['data'] is List<dynamic>) {
          postJson = data['posts']['data'];
        } else if (data['posts'] is List<dynamic>) {
          postJson = data['posts'];
        } else {
          setState(() {
            errorMessage =
                'Invalid API response format: Expected posts or posts.data';
            isLoadingCommented = false;
          });
          return;
        }

        setState(() {
          mostCommentedPosts =
              postJson.map((json) => Post.fromJson(json)).toList();
          isLoadingCommented = false;
          _hasMoreCommented = postJson.length == _limit;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load most commented posts: ${response.statusCode} - ${response.body}';
          isLoadingCommented = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching most commented posts: ${e.toString()}';
        isLoadingCommented = false;
      });
    }
  }

  Future<void> fetchMoreMostCommentedPosts() async {
    if (_isLoadingMoreCommented || !_hasMoreCommented) return;

    setState(() {
      _isLoadingMoreCommented = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http
          .get(
            Uri.parse(
              '$fetchMostCommentedPostsURL?page=${_pageCommented + 1}&limit=$_limit',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print(
        'More Most Commented Response: ${response.body}',
      ); // Debug raw response

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> postJson;

        if (data['posts'] is Map<String, dynamic> &&
            data['posts']['data'] is List<dynamic>) {
          postJson = data['posts']['data'];
        } else if (data['posts'] is List<dynamic>) {
          postJson = data['posts'];
        } else {
          setState(() {
            _isLoadingMoreCommented = false;
          });
          return;
        }

        setState(() {
          _pageCommented++;
          mostCommentedPosts.addAll(
            postJson.map((json) => Post.fromJson(json)).toList(),
          );
          _isLoadingMoreCommented = false;
          _hasMoreCommented = postJson.length == _limit;
        });
      } else {
        setState(() {
          _isLoadingMoreCommented = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMoreCommented = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Topluluk Enleri', 
            style: TextStyle(color: Colors.white),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 7, bottom: 7),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
              backgroundColor: Colors.black.withOpacity(0.2),
              elevation: 0,
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'En Beğenilen'),
              Tab(text: 'En Fazla Yorumlanan '),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  errorMessage = '';
                });
                await fetchMostLikedPosts();
                if (errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(errorMessage)));
                }
              },
              color: Colors.blue,
              backgroundColor: Colors.black.withOpacity(0.9),
              child:
                  isLoadingLiked
                      ? const Center(child: CircularProgressIndicator())
                      : mostLikedPosts.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage.isNotEmpty
                                  ? errorMessage
                                  : 'Gönderi yok',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            if (errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  onPressed: fetchMostLikedPosts,
                                  child: const Text('Retry'),
                                ),
                              ),
                          ],
                        ),
                      )
                      : CustomScrollView(
                        controller: _scrollControllerLiked,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == mostLikedPosts.length &&
                                    _isLoadingMoreLiked) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                final post = mostLikedPosts[index];
                                return Column(
                                  children: [
                                    PostWidget(
                                      post: post,
                                      parentScreen: 'leaderboard',
                                      currentUserId: currentUserId,
                                    ),
                                    const Divider(
                                      color: Colors.grey,
                                      height: 1,
                                    ),
                                  ],
                                );
                              },
                              childCount:
                                  mostLikedPosts.length +
                                  (_isLoadingMoreLiked ? 1 : 0),
                            ),
                          ),
                        ],
                      ),
            ),
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  errorMessage = '';
                });
                await fetchMostCommentedPosts();
                if (errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(errorMessage)));
                }
              },
              color: Colors.blue,
              backgroundColor: Colors.black.withOpacity(0.9),
              child:
                  isLoadingCommented
                      ? const Center(child: CircularProgressIndicator())
                      : mostCommentedPosts.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage.isNotEmpty
                                  ? errorMessage
                                  : 'Gönderi yok',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            if (errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  onPressed: fetchMostCommentedPosts,
                                  child: const Text('Retry'),
                                ),
                              ),
                          ],
                        ),
                      )
                      : CustomScrollView(
                        controller: _scrollControllerCommented,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == mostCommentedPosts.length &&
                                    _isLoadingMoreCommented) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                final post = mostCommentedPosts[index];
                                return Column(
                                  children: [
                                    PostWidget(
                                      post: post,
                                      parentScreen: 'leaderboard',
                                      currentUserId: currentUserId,
                                    ),
                                    const Divider(
                                      color: Colors.grey,
                                      height: 1,
                                    ),
                                  ],
                                );
                              },
                              childCount:
                                  mostCommentedPosts.length +
                                  (_isLoadingMoreCommented ? 1 : 0),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
