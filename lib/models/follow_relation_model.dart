class FollowRelationModel {
  final int? id;
  final int? followerId;
  final int? followedId;
  final String followerLogin;
  final String followedLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FollowRelationModel({
    this.id,
    this.followerId,
    this.followedId,
    required this.followerLogin,
    required this.followedLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowRelationModel.fromJson(Map<String, dynamic> json) {
    return FollowRelationModel(
      id: json['id'] as int?,
      followerId: json['follower_id'] as int?,
      followedId: json['followed_id'] as int?,
      followerLogin: (json['follower_login'] ?? '') as String,
      followedLogin: (json['followed_login'] ?? '') as String,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static List<FollowRelationModel> fromList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(FollowRelationModel.fromJson)
        .toList();
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
