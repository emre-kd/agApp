
class User {
  String? name;
  String? username;
  String? email;
  String? createdAt;
  String? image;
  String? coverImage;
  User({
    this.name,
    this.username,
    this.email,
    this.createdAt,
    this.image,
    this.coverImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      username: json['username'],
      email: json['email'],
      createdAt: json['created_at'],
      image: json['image'],
      coverImage: json['coverImage'],
    );
  }
}
