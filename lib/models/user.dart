class User {
  String? name;
  String? username;
  String? email;
  String? image;

  User({this.name, this.username, this.email, this.image});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      username: json['username'],
      email: json['email'],
      image: json['image'],
    );
  }
}
