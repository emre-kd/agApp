
class User {
  int? id;
  String? name;
  String? username;
  String? email;
  String? createdAt;
  String? image;
  String? coverImage;
  String? profileImage;
  User({
    this.id,
    this.name,
    this.username,
    this.email,
    this.createdAt,
    this.image,
    this.coverImage,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      createdAt: json['created_at'],
      image: json['image'],
      coverImage: json['coverImage'],
      profileImage: json['profileImage'],
    );
  }
}
