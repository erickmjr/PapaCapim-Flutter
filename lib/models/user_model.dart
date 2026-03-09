class UserModel {
  final int id;
  final int userId;
  final String token;
  final String ip;
  final String userLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.userId,
    required this.token,
    required this.ip,
    required this.userLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      userId: json["user_id"],
      token: json["token"],
      ip: json["ip"],
      userLogin: json["user_login"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }
}