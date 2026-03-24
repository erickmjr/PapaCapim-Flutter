class UserModel {
  final int? id;
  final int? sessionId;
  final String? token;
  final String? ip;
  final String userLogin;
  final String userName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    this.id,
    this.sessionId,
    this.token,
    this.ip,
    required this.userLogin,
    required this.userName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final isSessionPayload =
        json.containsKey('user_id') || json.containsKey('user_login');

    return UserModel(
      id: isSessionPayload
          ? json['user_id'] as int? ?? json['id'] as int?
          : json['id'] as int?,
      sessionId: json['session_id'] as int? ??
          (isSessionPayload ? json['id'] as int? : null),
      token: json['token'] as String?,
      ip: json['ip'] as String?,
      userLogin: (json['login'] ?? json['user_login'] ?? '') as String,
      userName: (json['name'] ?? json['user_name'] ?? '') as String,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  factory UserModel.fromUserJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      userLogin: (json['login'] ?? json['user_login'] ?? '') as String,
      userName: (json['name'] ?? json['user_name'] ?? '') as String,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  factory UserModel.fromSessionJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] as int?,
      sessionId: json['session_id'] as int? ?? json['id'] as int?,
      token: json['token'] as String?,
      ip: json['ip'] as String?,
      userLogin: (json['user_login'] ?? json['login'] ?? '') as String,
      userName: (json['user_name'] ?? json['name'] ?? '') as String,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  UserModel copyWith({
    int? id,
    int? sessionId,
    String? token,
    String? ip,
    String? userLogin,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      token: token ?? this.token,
      ip: ip ?? this.ip,
      userLogin: userLogin ?? this.userLogin,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<UserModel> fromList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromUserJson)
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'login': userLogin,
      'name': userName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id != null) data['id'] = id;
    if (sessionId != null) data['session_id'] = sessionId;
    if (token != null) data['token'] = token;
    if (ip != null) data['ip'] = ip;

    return data;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
