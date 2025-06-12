import 'package:agapp/constant.dart';
import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  final String profileImage;
  final String name;
  final String username;
  final String timeAgo;
  final String content;
  final String postImage;

  const Post({
    Key? key,
    required this.profileImage,
    required this.name,
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.postImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// User Info Row
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      profileImage.isNotEmpty
                          ? NetworkImage('$baseNormalURL/$profileImage')
                          : const AssetImage('assets/default-profile.png')
                              as ImageProvider,
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      username,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// Post Content
            if (content.isNotEmpty)
              Text(
                content,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            const SizedBox(height: 10),

            /// Post Image (if any)
            if (postImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '$baseNormalURL/$postImage',

                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
