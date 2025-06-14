// Community model
class Community {
  final int id;
  final String code;
  final String name;

  Community({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }
}