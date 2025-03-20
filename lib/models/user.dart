class User {
  int? id;
  String? name;
  String? username;
  String? image;
  String? email;
  String? token;

  User({
    this.id,
    this.name,
    this.username,
    this.image,
    this.email,
    this.token


  });

  // Function to conver json data ta user model
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'],
      name: json['user']['name'],
      username: json['user']['username'],
      image: json['user']['image'],
      email: json['user']['email'],
      token: json['token']

    );
  }

}