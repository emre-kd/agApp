import 'package:agapp/models/post.dart';
import 'package:agapp/models/user.dart' show User;

class Comment {
  final int id;
  final int userId;
  final int postId;
  final String comment;
  final DateTime createdAt;
  final User user;
  final Post post; 


  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.comment,
    required this.createdAt,
    required this.user,
    required this.post,
  });

factory Comment.fromJson(Map<String, dynamic> json) {

  return Comment(
    id: json['id'] as int? ?? 0,
    userId: json['user_id'] as int? ?? 0,
    postId: json['post_id'] as int? ?? 0,
    comment: json['comment'] as String? ?? '',
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),

    // User objesi json['user'] içinde olmadığı için post içinden manuel kuruyoruz
    user: User.fromJson(json['user']),


     post: Post.fromJson(json['post']),
  );
}
}