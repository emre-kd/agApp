class PostModel {
  final String text;
  final String media;
  final String createdAt;
  final String name;
  final String username;
  final String profileImage;

  PostModel({
    required this.text,
    required this.media,
    required this.createdAt,
    required this.name,
    required this.username,
    required this.profileImage,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return PostModel(
      text: json['text'] ?? '',
      media: json['media'] ?? '',
      createdAt: json['created_at'] ?? '',
      name: user['name'] ?? '',
      username: user['username'] ?? '',
      profileImage: user['image'] ?? '',
    );
  }
}
