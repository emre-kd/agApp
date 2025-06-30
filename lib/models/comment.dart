import 'package:agapp/models/user.dart' show User;

class Comment {
  final int id;
  final int userId;
  final int postId;
  final String comment;
  final DateTime createdAt;
  final User user;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.comment,
    required this.createdAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
    );
  }
}