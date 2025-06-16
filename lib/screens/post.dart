// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:agapp/constant.dart';
import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:agapp/models/post.dart' as post_model;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostWidget extends StatefulWidget {
  final post_model.Post post;
  final String parentScreen;

  const PostWidget({Key? key, required this.post, required this.parentScreen})
    : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(userDetailsURL),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      /* print('User ID: ${data['id']}');
      print('User Community ID: ${data['community_id']}');
      print('User Name: ${data['name']}');
      print('User Email: ${data['email']}');
      print('User Username: ${data['username']}');
      print('User Created At: ${data['created_at']}');
      */
      prefs.setInt('id', data['id']);
      setState(() {
        currentUserId = data['id'];
      });
    } else {
      print('Failed to fetch user info');
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

      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        // Show SnackBar immediately
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Post deleted successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Delay navigation to ensure SnackBar is visible
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
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color.fromARGB(255, 224, 218, 218),
              width: 0.5,
            ), // Top border here
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// User Info Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        widget.post.profileImage.isNotEmpty
                            ? NetworkImage(
                              '$baseNormalURL/${widget.post.profileImage}',
                            )
                            : null, // No background image if profileImage is empty
                    radius: 22,
                    backgroundColor:
                        Colors.white, // Background color for fallback
                    child:
                        widget.post.profileImage.isEmpty
                            ? const Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 35,
                            )
                            : null, // Show icon only if no image
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.post.username,
                        style: TextStyle(
                           color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.post.createdAt,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                  if (currentUserId == widget.post.userId)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'update') {
                          // Add your update logic here
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Silme İşlemi'),
                                  ],
                                ),
                                content: const Text(
                                  'Bu gönderiyi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
                                  style: TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Text(
                                      'İptal',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _deletePost(
                                        widget.post.id,
                                      ); // Call API to delete
                                      Navigator.of(
                                        context,
                                      ).pop(); // Close dialog
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sil',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              );
                            },
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 28,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      itemBuilder:
                          (BuildContext context) => [
                            PopupMenuItem(
                              value: 'update',
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    'Güncelle',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Sil',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (widget.post.text.isNotEmpty)
                Text(
                  widget.post.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              const SizedBox(height: 10),

              if (widget.post.media.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    '$baseNormalURL/${widget.post.media}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              const SizedBox(height: 10),

              // Like, Repost, and Comment section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: InkWell(
                      onTap: () {
                        print("Like tapped");
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: InkWell(
                      onTap: () {
                        print("Repost tapped");
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.repeat, color: Colors.white, size: 22),
                          SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: InkWell(
                      onTap: () {
                        print("Comment tapped");
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
