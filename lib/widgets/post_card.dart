import 'package:flutter/material.dart';
import 'package:papa_capim/models/post.dart';
import 'package:papa_capim/models/user.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/user_avatar.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.user,
    this.isOwner = false,
    this.onDelete,
    this.onReply,
  });

  final Post post;
  final User user;
  final bool isOwner;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = widget.post.isLiked;
    _likes = widget.post.likes;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.leaf.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.profile,
              arguments: widget.user.username,
            ),
            child: UserAvatar(
              name: widget.user.name,
              color: widget.user.avatarColor,
              size: AvatarSize.md,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.profile,
                          arguments: widget.user.username,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.bark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '@${widget.user.username}',
                                style: TextStyle(
                                  color: AppColors.moss.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '- ${widget.post.timestamp}',
                              style: TextStyle(
                                color: AppColors.moss.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.isOwner && widget.onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        color: AppColors.moss.withOpacity(0.6),
                        onPressed: widget.onDelete,
                        tooltip: 'Excluir postagem',
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.post.content,
                  style: const TextStyle(
                    color: AppColors.bark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _liked ? AppColors.sun : AppColors.moss,
                        size: 18,
                      ),
                    ),
                    Text(
                      '$_likes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _liked ? AppColors.sun : AppColors.moss,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: widget.onReply,
                      icon: const Icon(
                        Icons.mode_comment_outlined,
                        color: AppColors.moss,
                        size: 18,
                      ),
                    ),
                    Text(
                      '${widget.post.replies}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.moss,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
