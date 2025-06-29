// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/profile.dart';
import 'package:agapp/screens/searched_profile.dart';
import 'package:flutter/material.dart';
import 'package:agapp/models/post.dart' as post_model;
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    // Initialize video controller if the media is a video
    if (_isVideo(widget.post.media)) {
      _videoController = VideoPlayerController.network(
          '$baseNormalURL/${widget.post.media}',
        )
        ..initialize()
            .then((_) {
              setState(() {
                _isVideoInitialized = true;
              });
            })
            .catchError((error) {
              print('Video initialization error: $error');
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // Helper method to determine if the media is a video based on file extension
  bool _isVideo(String mediaUrl) {
    // Alternatively, check `widget.post.mediaType` if available
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => mediaUrl.toLowerCase().endsWith(ext));
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Post başarıyla silindi!"),
            backgroundColor: Color.fromARGB(255, 0, 145, 230),
            duration: Duration(seconds: 2),
          ),
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
        }
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Bir hata oluştu';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ağ hatası oluştu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[800]!, width: 0.5),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => SearchedProfile(
                                userId: widget.post.userId,
                                userName: widget.post.name,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[600]!,
                          width: 0.5,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage:
                            widget.post.profileImage.isNotEmpty
                                ? NetworkImage(
                                  '$baseNormalURL/${widget.post.profileImage}',
                                )
                                : null,
                        radius: 22,
                        backgroundColor: Colors.grey[900],
                        child:
                            widget.post.profileImage.isEmpty
                                ? Icon(Icons.person, color: Colors.grey[400])
                                : null,
                      ),
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
                                builder:
                                    (_) => SearchedProfile(
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
                                builder:
                                    (_) => SearchedProfile(
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
                        widget.post.createdAt,
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
              if (widget.post.media.isNotEmpty) _buildMediaWidget(),
              const SizedBox(height: 12),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // New method to build the media widget (image or video)
  Widget _buildMediaWidget() {
    if (_isVideo(widget.post.media)) {
      return _buildVideoPlayer();
    } else {
      return _buildImageViewer();
    }
  }

  // Widget for displaying images
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
                    imageProvider: NetworkImage(
                      '$baseNormalURL/${widget.post.media}',
                    ),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    errorBuilder:
                        (context, error, stackTrace) => Center(
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
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[800]!, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.network(
            '$baseNormalURL/${widget.post.media}',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder:
                (_, __, ___) => Container(
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
      ),
    );
  }

  // Widget for displaying videos
  Widget _buildVideoPlayer() {
    if (_videoController == null || !_isVideoInitialized) {
      return Container(
        height: 200,
        color: Colors.grey[900],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[800]!, width: 0.5),
          borderRadius: BorderRadius.circular(12),
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
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
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
      itemBuilder:
          (BuildContext context) => [
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
                  'Post silinsin mi ?',
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
          icon: Icons.favorite_border,
          label: '1',
          onTap: () => print("Like tapped"),
        ),
    
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          label: '5',
          onTap: () => print("Comment tapped"),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 20),
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
