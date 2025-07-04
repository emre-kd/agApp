// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_field
import 'dart:convert';
import 'package:agapp/models/comment.dart';
import 'package:agapp/models/post.dart';
import 'package:agapp/screens/comments_page.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/post.dart';
import 'package:agapp/screens/update-profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constant.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userData = {};
  List<Post> posts = [];
  List<Post> likedPosts = [];
  List<Comment> comments = [];
  bool isLoading = true;
  bool isLoadingMorePosts = false;
  bool isLoadingMoreLikes = false;
  bool isLoadingMoreComments = false;
  String errorMessage = '';
  int? currentUserId;
  int postsPage = 1;
  int likesPage = 1;
  int commentsPage = 1;
  final int limit = 5;
  final int limitComments = 20;
  bool hasMorePosts = true;
  bool hasMoreLikes = true;
  bool hasMoreComments = true;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _createdAtController;
  late TextEditingController _passwordController;

  // Scroll Controllers
  final ScrollController _postsScrollController = ScrollController();
  final ScrollController _likesScrollController = ScrollController();
  final ScrollController _commentsScrollController = ScrollController();

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
    fetchLikedPosts();
    fetchUserComments();

    _postsScrollController.addListener(() {
      if (_postsScrollController.position.pixels >=
              _postsScrollController.position.maxScrollExtent - 200 &&
          !isLoadingMorePosts &&
          hasMorePosts) {
        fetchMorePosts();
      }
    });

    _likesScrollController.addListener(() {
      if (_likesScrollController.position.pixels >=
              _likesScrollController.position.maxScrollExtent - 200 &&
          !isLoadingMoreLikes &&
          hasMoreLikes) {
        fetchMoreLikedPosts();
      }
    });

    _commentsScrollController.addListener(() {
      if (_commentsScrollController.position.pixels >=
              _commentsScrollController.position.maxScrollExtent - 200 &&
          !isLoadingMoreComments &&
          hasMoreComments) {
        fetchMoreComments();
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
    _postsScrollController.dispose();
    _likesScrollController.dispose();
    _commentsScrollController.dispose();
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

    setState(() => isLoading = true);

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
          userData =
              decodedResponse is List<dynamic> && decodedResponse.isNotEmpty
                  ? decodedResponse[0] as Map<String, dynamic>
                  : decodedResponse is Map<String, dynamic>
                  ? decodedResponse
                  : {};
          if (userData.isEmpty) errorMessage = 'Unexpected response format';
          _nameController.text = userData['name']?.toString() ?? '';
          _userNameController.text = userData['username']?.toString() ?? '';
          _emailController.text = userData['email']?.toString() ?? '';
          _createdAtController.text = userData['created_at']?.toString() ?? '';
          currentUserId = userData['id']?.toInt();
          isLoading = false;
        });
        if (currentUserId != null) await prefs.setInt('id', currentUserId!);
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
      postsPage = 1;
      hasMorePosts = true;
      posts.clear();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$fetchUserPostURL?page=$postsPage&limit=$limit'),
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
          hasMorePosts = postJson.length == limit;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching posts: ${e.toString()}';
      });
    }
  }

  Future<void> fetchMorePosts() async {
    if (isLoadingMorePosts || !hasMorePosts) return;

    setState(() => isLoadingMorePosts = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$fetchUserPostURL?page=${postsPage + 1}&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postJson = data['posts'];
        setState(() {
          postsPage++;
          posts.addAll(postJson.map((json) => Post.fromJson(json)).toList());
          isLoadingMorePosts = false;
          hasMorePosts = postJson.length == limit;
        });
      } else {
        setState(() => isLoadingMorePosts = false);
      }
    } catch (e) {
      setState(() => isLoadingMorePosts = false);
    }
  }

  Future<void> fetchLikedPosts() async {
    setState(() {
      likesPage = 1;
      hasMoreLikes = true;
      likedPosts.clear();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$baseURL/user/liked-posts?page=$likesPage&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postJson = data['posts'];
        setState(() {
          likedPosts = postJson.map((json) => Post.fromJson(json)).toList();
          hasMoreLikes = postJson.length == limit;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching liked posts: ${e.toString()}';
      });
    }
  }

  Future<void> fetchMoreLikedPosts() async {
    if (isLoadingMoreLikes || !hasMoreLikes) return;

    setState(() => isLoadingMoreLikes = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(
          '$baseURL/user/liked-posts?page=${likesPage + 1}&limit=$limit',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postJson = data['posts'];
        setState(() {
          likesPage++;
          likedPosts.addAll(
            postJson.map((json) => Post.fromJson(json)).toList(),
          );
          isLoadingMoreLikes = false;
          hasMoreLikes = postJson.length == limit;
        });
      } else {
        setState(() => isLoadingMoreLikes = false);
      }
    } catch (e) {
      setState(() => isLoadingMoreLikes = false);
    }
  }

  Future<void> fetchUserComments() async {
    setState(() {
      commentsPage = 1;
      hasMoreComments = true;
      comments.clear();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(
          '$baseURL/user/comments?page=$commentsPage&limit=$limitComments',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> commentJson = data['comments']['data'];
        setState(() {
          comments = commentJson.map((json) => Comment.fromJson(json)).toList();
          hasMoreComments = commentJson.length == limitComments;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching comments: ${e.toString()}';
      });
    }
  }

  Future<void> fetchMoreComments() async {
    if (isLoadingMoreComments || !hasMoreComments) return;

    setState(() => isLoadingMoreComments = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(
          '$baseURL/user/comments?page=${commentsPage + 1}&limit=$limitComments',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> commentJson = data['comments']['data'];
        setState(() {
          commentsPage++;
          comments.addAll(
            commentJson.map((json) => Comment.fromJson(json)).toList(),
          );
          isLoadingMoreComments = false;
          hasMoreComments = commentJson.length == limitComments;
        });
      } else {
        setState(() => isLoadingMoreComments = false);
      }
    } catch (e) {
      setState(() => isLoadingMoreComments = false);
    }
  }

  Future<void> refreshAllData() async {
    setState(() => isLoading = true);
    await Future.wait([
      fetchUserData(),
      fetchUserPosts(),
      fetchLikedPosts(),
      fetchUserComments(),
    ]);
    setState(() => isLoading = false);
  }

  void onCommentTap(Comment comment) {
    print('Tapped comment ID: ${comment.id} on Post ID: ${comment.postId}');
    // Add navigation to post or other logic here
  }

  String formatCreatedAt(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MM yyyy').format(date) + ' tarihinde katıldı';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: RefreshIndicator(
              onRefresh: refreshAllData,
              color: Colors.white,
              backgroundColor: Colors.black.withOpacity(0.8),
              child: NestedScrollView(
                headerSliverBuilder:
                    (context, innerBoxIsScrolled) => [
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
                          child: FloatingActionButton(
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ),
                                ),
                            backgroundColor: Colors.black.withOpacity(0.2),
                            elevation: 0,
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 10.0,
                              top: 10.0,
                            ),
                            child: OutlinedButton(
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateProfile(),
                                    ),
                                  ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                backgroundColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 5.0,
                                ),
                              ),
                              child: const Text(
                                'Profili Güncelle',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
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
                            Positioned(
                              bottom: -75,
                              left: 20,
                              child: Container(
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
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ).copyWith(top: 90),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              // TabBar moved below header
                            ],
                          ),
                        ),
                      ),
                    ],
                body: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(text: 'Gönderiler'),
                        Tab(text: 'Beğeniler'),
                        Tab(text: 'Yorumlar'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Gönderiler
                          posts.isEmpty
                              ? const Center(
                                child: Text(
                                  'Gönderi yok',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                controller: _postsScrollController,
                                itemCount:
                                    posts.length + (isLoadingMorePosts ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == posts.length &&
                                      isLoadingMorePosts) {
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
                                },
                              ),

                          // Beğeniler
                          likedPosts.isEmpty
                              ? const Center(
                                child: Text(
                                  'Beğenilen gönderi yok',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                controller: _likesScrollController,
                                itemCount:
                                    likedPosts.length +
                                    (isLoadingMoreLikes ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == likedPosts.length &&
                                      isLoadingMoreLikes) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }
                                  final post = likedPosts[index];
                                  return PostWidget(
                                    post: post,
                                    parentScreen: 'profile',
                                    currentUserId: currentUserId,
                                  );
                                },
                              ),

    

                              comments.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Yorum yok',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      controller: _commentsScrollController,
                                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                                      itemCount: comments.length + (isLoadingMoreComments ? 1 : 0),
                                      separatorBuilder: (context, index) => const Divider(
                                        color: Colors.white24,
                                        thickness: 1,
                                        height: 32,
                                      ), // Full-width divider between comments
                                      itemBuilder: (context, index) {
                                        if (index == comments.length && isLoadingMoreComments) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          );
                                        }

                                        final comment = comments[index];
                                        final post = comment.post;

                                        // Calculate approximate height for the vertical line
                                        final bool hasMedia = post.media.toString().isNotEmpty &&
                                            (post.media.toLowerCase().endsWith('.jpg') ||
                                                post.media.toLowerCase().endsWith('.jpeg') ||
                                                post.media.toLowerCase().endsWith('.png') ||
                                                post.media.toLowerCase().endsWith('.gif') ||
                                                post.media.toLowerCase().endsWith('.webp') ||
                                                post.media.toLowerCase().endsWith('.mp4') ||
                                                post.media.toLowerCase().endsWith('.mov') ||
                                                post.media.toLowerCase().endsWith('.avi') ||
                                                post.media.toLowerCase().endsWith('.mkv'));
                                        final bool hasText = post.text.trim().isNotEmpty;

                                        // Adjust vertical line height based on content
                                        double verticalLineHeight;
                                        if (hasMedia && hasText) {
                                          verticalLineHeight = 290; // Text + media + divider
                                        } else if (hasMedia) {
                                          verticalLineHeight = 250; // Media + divider
                                        } else if (hasText) {
                                          verticalLineHeight = 180; // Text + divider
                                        } else {
                                          verticalLineHeight = 140; // No text, no media + divider
                                        }

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CommentsPage(
                                                  post: comment.post,
                                                  parentScreen: 'searchedProfile',
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Single vertical line for both post and comment
                                                Container(
                                                  width: 2,
                                                  height: verticalLineHeight,
                                                  margin: const EdgeInsets.only(right: 16, left: 4),
                                                  color: Colors.white24,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // --- POST PREVIEW ---
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 18,
                                                            backgroundImage: post.user.image != null
                                                                ? NetworkImage('$baseNormalURL/${post.user.image}')
                                                                : null,
                                                            backgroundColor: Colors.grey[700],
                                                            child: post.user.image == null
                                                                ? const Icon(
                                                                    Icons.person,
                                                                    color: Colors.white70,
                                                                    size: 20,
                                                                    semanticLabel: 'User avatar',
                                                                  )
                                                                : null,
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: Row(
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    post.user.name ?? 'Unknown',
                                                                    style: const TextStyle(
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 16,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Flexible(
                                                                  child: Text(
                                                                    post.user.username ?? 'unknown',
                                                                    style: TextStyle(
                                                                      color: Colors.grey[400],
                                                                      fontSize: 14,
                                                                      fontStyle: FontStyle.italic,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Text(
                                                                  timeago.format(post.createdAt, locale: 'tr'),
                                                                  style: const TextStyle(
                                                                    color: Colors.white38,
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (hasText) ...[
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          post.text.replaceAll('\n', ' ').trim().substring(
                                                                0,
                                                                post.text.length > 80 ? 80 : post.text.length,
                                                              ) +
                                                              (post.text.length > 80 ? '...' : ''),
                                                          style: const TextStyle(
                                                            color: Colors.white70,
                                                            fontSize: 15,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      ],
                                                      if (hasMedia) ...[
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 12, left: 8),
                                                          child: Builder(
                                                            builder: (context) {
                                                              final mediaUrl = '$baseNormalURL/${post.media}';
                                                              final isImage = post.media.toLowerCase().endsWith('.jpg') ||
                                                                  post.media.toLowerCase().endsWith('.jpeg') ||
                                                                  post.media.toLowerCase().endsWith('.png') ||
                                                                  post.media.toLowerCase().endsWith('.gif') ||
                                                                  post.media.toLowerCase().endsWith('.webp');
                                                              final isVideo = post.media.toLowerCase().endsWith('.mp4') ||
                                                                  post.media.toLowerCase().endsWith('.mov') ||
                                                                  post.media.toLowerCase().endsWith('.avi') ||
                                                                  post.media.toLowerCase().endsWith('.mkv');

                                                              if (isImage) {
                                                                return ClipRRect(
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  child: Image.network(
                                                                    mediaUrl,
                                                                    height: 140,
                                                                    width: double.infinity,
                                                                    fit: BoxFit.cover,
                                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                                      height: 140,
                                                                      color: Colors.grey[800],
                                                                      child: const Center(
                                                                        child: Icon(
                                                                          Icons.broken_image,
                                                                          color: Colors.white54,
                                                                          size: 30,
                                                                          semanticLabel: 'Broken image',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              } else if (isVideo) {
                                                                return Container(
                                                                  height: 140,
                                                                  width: double.infinity,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.black54,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: const Center(
                                                                    child: Icon(
                                                                      Icons.video_library,
                                                                      color: Colors.white70,
                                                                      size: 48,
                                                                      semanticLabel: 'Video',
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                return const SizedBox.shrink();
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                      // Separator between post preview and comment
                                                      const SizedBox(height: 12),
                                                      const Divider(
                                                        color: Colors.white24,
                                                        thickness: 0.5,
                                                        height: 16,
                                                        indent: 8,
                                                      ),
                                                      const SizedBox(height: 12),
                                                      // --- COMMENT ---
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 22,
                                                            backgroundImage: comment.user.image != null
                                                                ? NetworkImage('$baseNormalURL/${comment.user.image}')
                                                                : null,
                                                            backgroundColor: Colors.grey[800],
                                                            child: comment.user.image == null
                                                                ? const Icon(
                                                                    Icons.person,
                                                                    color: Colors.white70,
                                                                    size: 26,
                                                                    semanticLabel: 'User avatar',
                                                                  )
                                                                : null,
                                                          ),
                                                          const SizedBox(width: 16),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Flexible(
                                                                      child: Text(
                                                                        comment.user.name ?? 'Unknown',
                                                                        style: const TextStyle(
                                                                          color: Colors.white,
                                                                          fontWeight: FontWeight.w600,
                                                                          fontSize: 16,
                                                                        ),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 8),
                                                                    Flexible(
                                                                      child: Text(
                                                                        comment.user.username ?? 'unknown',
                                                                        style: TextStyle(
                                                                          color: Colors.grey[400],
                                                                          fontSize: 14,
                                                                          fontStyle: FontStyle.italic,
                                                                        ),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 8),
                                                                    Text(
                                                                      timeago.format(comment.createdAt, locale: 'tr'),
                                                                      style: const TextStyle(
                                                                        color: Colors.white38,
                                                                        fontSize: 13,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(height: 8),
                                                                Text(
                                                                  comment.comment,
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 15,
                                                                    height: 1.4,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
