class Post {
  final int id; // Post ID
  final String text;
  final String media;
  final String createdAt;
  final String name;
  final String username;
  final String profileImage;
  final int userId; 
  int commentsCount;


  Post({
    required this.id,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.name,
    required this.username,
    required this.profileImage,
    required this.userId,
    required this.commentsCount,


  });

 factory Post.fromJson(Map<String, dynamic> json) {
  final user = json['user'] ?? {};
  return Post(
    id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'), // Convert to int
    text: json['text']?.toString() ?? '',
    media: json['media']?.toString() ?? '',
    createdAt: json['created_at']?.toString() ?? '',
    name: user['name']?.toString() ?? '',
    username: user['username']?.toString() ?? '',
    profileImage: user['image']?.toString() ?? '',
    userId: user['id'] is int ? user['id'] : int.parse(user['id']?.toString() ?? '0'), // Convert to int
    commentsCount: json['comments_count'] ?? 0,

  );
}
}
