class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.replies,
    required this.isLiked,
  });

  final String id;
  final String userId;
  final String content;
  final String timestamp;
  final int likes;
  final int replies;
  final bool isLiked;

  Post copyWith({
    int? likes,
    bool? isLiked,
  }) {
    return Post(
      id: id,
      userId: userId,
      content: content,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      replies: replies,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
