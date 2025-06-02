class User {
  String? name;
  String? username;
  String? email;
  String? createdAt;
  String? image;

  User({
    this.name,
    this.username,
    this.email,
    this.createdAt,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      username: json['username'],
      email: json['email'],
      createdAt: json['created_at'],
      image: json['image'],
    );
  }
}
