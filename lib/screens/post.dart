// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:agapp/screens/comments_page.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/leaderboard.dart';
import 'package:agapp/screens/profile.dart';
import 'package:agapp/screens/searched_profile.dart';
import 'package:flutter/material.dart';
import 'package:agapp/models/post.dart' as post_model;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class PostWidget extends StatefulWidget {
  final post_model.Post post;
  final String parentScreen;
  final int? currentUserId;

  const PostWidget({
    Key? key,
    required this.post,
    required this.parentScreen,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    if (_isVideo(widget.post.media)) {
      _initializeVideoPlayer();
    }
    _checkLikeStatus();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  bool _isVideo(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) return false;
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => mediaUrl.toLowerCase().endsWith(ext));
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.network(
        '$baseNormalURL/${widget.post.media}',
      );
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
        _isVideoError = false;
      });
    } catch (error) {
      print('Video initialization error: $error');
      setState(() {
        _isVideoError = true;
      });
     /* showTopPopUp(
        context,
        message: 'Video yüklenemedi',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
      */
    }
  }

 Future<void> _checkLikeStatus() async {
  if (!mounted) return; // Early exit if widget is unmounted

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    print('No token found in SharedPreferences');
    if (mounted) { // Check mounted before showing popup
      showTopPopUp(
        context,
        message: 'Oturum açmanız gerekiyor',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    }
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('$likePostURL/${widget.post.id}/like-status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 && mounted) { // Check mounted before setState
      final data = jsonDecode(response.body);
      setState(() {
        _isLiked = data['is_liked'] == true;
        _likeCount = data['like_count'] ?? widget.post.likesCount ?? 0;
      });
    } else if (mounted) { // Check mounted before showing popup
      print('Failed to fetch like status: ${response.statusCode} - ${response.body}');
     /* showTopPopUp(
        context,
        message: 'Hata: Like durumu alınamadı (${response.statusCode})',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
      */
    }
  } catch (e) {
    print('Error checking like status: $e');
    if (mounted) { // Check mounted before showing popup
      showTopPopUp(
        context,
        message: 'Ağ hatası oluştu',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

Future<void> _toggleLike() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    print('No token found in SharedPreferences');
    showTopPopUp(
      context,
      message: 'Oturum açmanız gerekiyor',
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('$likePostURL/${widget.post.id}/like'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _isLiked = data['is_liked'] == true;
        _likeCount = data['like_count'] ?? widget.post.likesCount ?? 0;
      });
      showTopPopUp(
        context,
        message: _isLiked ? 'Gönderi beğenildi' : 'Beğeni kaldırıldı',
        backgroundColor: const Color.fromARGB(255, 0, 145, 230),
        duration: const Duration(seconds: 2),
      );
    } else if (response.statusCode == 404) {
      print('Failed to toggle like: Post not found - ${response.statusCode} - ${response.body}');
      showTopPopUp(
        context,
        message: 'Hata: Gönderi bulunamadı. Gönderi silinmiş veya erişilemez olabilir.',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } else {
      print('Failed to toggle like: ${response.statusCode} - ${response.body}');
      final error = jsonDecode(response.body)['message'] ?? 'Bir hata oluştu';
      showTopPopUp(
        context,
        message: 'Hata: $error',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    }
  } catch (e) {
    print('Error toggling like: $e');
    showTopPopUp(
      context,
      message: 'Ağ hatası oluştu',
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    );
  }
}

  Future<void> _deletePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.delete(
        Uri.parse('$deleteUserPostURL/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        showTopPopUp(
          context,
          message: 'Post başarıyla silindi!',
          backgroundColor: const Color.fromARGB(255, 0, 145, 230),
          duration: const Duration(seconds: 2),
        );

        if (widget.parentScreen == 'home') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        } else if (widget.parentScreen == 'profile') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        }  else if (widget.parentScreen == 'leaderboard') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Leaderboard()),
          );
        } 
         else if (widget.parentScreen == 'searchedProfile') {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
        else if (widget.parentScreen == 'notification') {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Bir hata oluştu';
        showTopPopUp(
          context,
          message: 'Hata: $error',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    print('PostWidget build - ID: ${widget.post.id}, Comments: ${widget.post.commentsCount}');
   return Card(
  color: Colors.black,
  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
  elevation: 0,
  child: Container(
    decoration: BoxDecoration(
      border: const Border(
        bottom: BorderSide(
          color: Colors.white24,
          width: 0.5,
        ),
      ),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchedProfile(
                      userId: widget.post.userId,
                      userName: widget.post.name,
                    ),
                  ),
                );
              },
          
                child: CircleAvatar(
                  backgroundImage: widget.post.profileImage.isNotEmpty
                      ? NetworkImage('$baseNormalURL/${widget.post.profileImage}')
                      : null,
                  radius: 22,
                  backgroundColor: Colors.grey[900],
                  child: widget.post.profileImage.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[400])
                      : null,
                ),
              ),
        
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchedProfile(
                            userId: widget.post.userId,
                            userName: widget.post.name,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      widget.post.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchedProfile(
                            userId: widget.post.userId,
                            userName: widget.post.name,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '${widget.post.username}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  DateFormat('MMM d, yyyy ').format(widget.post.createdAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (widget.currentUserId == widget.post.userId)
                  _buildPostMenu(context),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.post.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.post.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        if (widget.post.media.isNotEmpty)
          _buildMediaWidget(),
        const SizedBox(height: 12),
        _buildActionButtons(),
      ],
    ),
  ),
);

  }

  Widget _buildMediaWidget() {
    if (_isVideo(widget.post.media)) {
      return _buildVideoPlayer();
    } else {
      return _buildImageViewer();
    }
  }

  Widget _buildImageViewer() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                children: [
                  PhotoView(
                    imageProvider: NetworkImage('$baseNormalURL/${widget.post.media}'),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        
          child: Image.network(
            '$baseNormalURL/${widget.post.media}',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey[900],
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey[600],
                  size: 40,
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isVideoError || _videoController == null || !_isVideoInitialized) {
      return GestureDetector(
        onTap: _initializeVideoPlayer,
        child: Container(
          height: 200,
          color: Colors.grey[900],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  color: Colors.grey[600],
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Video yüklenemedi. Tekrar deneyin.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            IconButton(
              icon: Icon(
                _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostMenu(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'delete') {
          _showDeleteDialog(context);
        }
      },
      icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[800]!, width: 0.5),
      ),
      color: Colors.grey[900],
      elevation: 2,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.grey[300], size: 20),
              const SizedBox(width: 8),
              Text(
                'Sil',
                style: TextStyle(color: Colors.grey[300], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_rounded, color: Colors.red[400], size: 40),
                const SizedBox(height: 16),
                const Text(
                  'Post silinsin mi?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bu eylem geri alınamaz. Gönderi kalıcı olarak silinecektir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[700]!),
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _deletePost(widget.post.id);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sil',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          color: _isLiked ? Colors.red : Colors.grey[400],
          label: _likeCount.toString(),
          onTap: _toggleLike,
        ),
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          label: (widget.post.commentsCount).toString(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentsPage(
                  post: widget.post,
                  currentUserId: widget.currentUserId,
                  parentScreen: widget.parentScreen,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey[400], size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}