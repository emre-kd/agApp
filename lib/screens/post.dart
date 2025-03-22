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
    return Container(
      width: double.infinity,
      
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        color: Colors.black,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Padding(
        
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(profileImage),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white)),
                      Text(username, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Text(timeAgo, style: const TextStyle(color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white,),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Post Content
            Text(
              content,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Colors.white),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            // Post Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                postImage,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
