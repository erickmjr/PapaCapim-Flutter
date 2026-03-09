class UserModel {
  final int id;
  final String token;
  final String ip;
  final String userLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get userId => userLogin;

  UserModel({
    required this.id,
    required this.token,
    required this.ip,
    required this.userLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      token: json["token"],
      ip: json["ip"],
      userLogin: json["user_login"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }
}
