// lib/screens/comments_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:agapp/models/comment.dart';
import 'package:agapp/models/post.dart' as post_model;
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/post.dart';
import 'package:agapp/screens/searched_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsPage extends StatefulWidget {
  final post_model.Post post;
  final int? currentUserId;
  final String parentScreen;

  const CommentsPage({
    Key? key,
    required this.post,
    this.currentUserId,
    required this.parentScreen,
  }) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments({bool isLoadMore = false}) async {
    if (_isLoading || (!_hasMore && isLoadMore)) return;

    setState(() {
      _isLoading = true;
      if (!isLoadMore) {
        _currentPage = 1; // Reset page for refresh
        _hasMore = true; // Reset hasMore for refresh
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      showTopPopUp(
        context,
        message: 'Oturum açmanız gerekiyor',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$fetchCommentsURL/${widget.post.id}/comments?page=$_currentPage&per_page=$_perPage',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> commentData = data['data'];
        final meta = data['meta'];

        setState(() {
          if (isLoadMore) {
            _comments.addAll(
              commentData.map((json) => Comment.fromJson(json)).toList(),
            );
          } else {
            _comments =
                commentData.map((json) => Comment.fromJson(json)).toList();
          }
          _hasMore = meta['current_page'] < meta['last_page'];
          _currentPage = meta['current_page'] + 1;
          _isLoading = false;
        });
      } else {
        showTopPopUp(
          context,
          message: 'Hata: Yorumlar alınamadı (${response.statusCode})',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      showTopPopUp(
        context,
        message: 'Ağ hatası oluştu',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchComments(isLoadMore: true);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      showTopPopUp(
        context,
        message: 'Oturum açmanız gerekiyor',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(addCommentURL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'post_id': widget.post.id,
          'comment': _commentController.text,
        }),
      );

      print(response.body);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _comments.insert(0, Comment.fromJson(data['data']));
          widget.post.commentsCount++;
          _commentController.clear();
        });
        // Close the keyboard
        FocusManager.instance.primaryFocus?.unfocus();
        // Scroll to the top to show the latest comment
        _scrollController.jumpTo(0);
        showTopPopUp(
          context,
          message: 'Yorum eklendi',
          backgroundColor: const Color.fromARGB(255, 0, 145, 230),
          duration: const Duration(seconds: 2),
        );
      } else {
        showTopPopUp(
          context,
          message: 'Hata: Yorum eklenemedi (${response.statusCode})',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      showTopPopUp(
        context,
        message: 'Ağ hatası oluştu',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[400]),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
        title: Text(
          'Yorumlar',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchComments(isLoadMore: false),
              color: Colors.white, // White spinner
              backgroundColor: Colors.black, // Black background
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    PostWidget(
                      post: widget.post,
                      currentUserId: widget.currentUserId,
                      parentScreen: widget.parentScreen,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ' Yorumlar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCommentsList(),
                          if (_isLoading && _hasMore)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_comments.isEmpty && !_isLoading) {
      return const Center(
        child: Text(
          'Henüz yorum yok.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return Column(
  children: _comments.map((comment) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchedProfile(
                    userId: comment.user.id!,
                    userName: comment.user.username!,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: comment.user.image != null
                  ? NetworkImage('$baseNormalURL/${comment.user.image}')
                  : null,
              backgroundColor: Colors.grey[900],
              child: comment.user.image == null
                  ? Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 20,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SearchedProfile(
                                      userId: comment.user.id!,
                                      userName: comment.user.username!,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                comment.user.name ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '@${comment.user.username}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      timeago.format(comment.createdAt, locale: 'tr'),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.comment,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }).toList(),
);

  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLength: 100,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Yorum yap',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[850],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Colors.grey[400]),
            onPressed: _addComment,
          ),
        ],
      ),
    );
  }
}

// lib/utils/top_pop_up.dart

void showTopPopUp(
  BuildContext context, {
  required String message,
  Color backgroundColor = Colors.black,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: 80.0, // Below AppBar (~56.0) and status bar (~20-30 pixels)
          left: 16.0,
          right: 16.0,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);

  // Remove the pop-up after the specified duration
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
