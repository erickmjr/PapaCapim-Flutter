import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/models/post_model.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/theme.dart';

class ApiPostCard extends StatefulWidget {
  const ApiPostCard({
    super.key,
    required this.post,
    required this.sessionToken,
    required this.currentUserLogin,
    this.isOwner = false,
    this.onReply,
    this.onDeleted,
  });

  final PostModel post;
  final String sessionToken;
  final String currentUserLogin;
  final bool isOwner;
  final VoidCallback? onReply;
  final VoidCallback? onDeleted;

  @override
  State<ApiPostCard> createState() => _ApiPostCardState();
}

class _ApiPostCardState extends State<ApiPostCard> {
  static final Map<int, String> _replyTargetLoginCache = {};

  bool _isLoadingLikes = true;
  bool _isSubmittingLike = false;
  bool _liked = false;
  int _likes = 0;
  int? _likeId;
  String? _replyTargetLogin;

  @override
  void initState() {
    super.initState();
    final currentLogin = widget.post.userLogin.trim();
    if (currentLogin.isNotEmpty) {
      _replyTargetLoginCache[widget.post.id] = currentLogin;
    }
    _primeReplyTargetLogin();
    _loadLikes();
  }

  void _primeReplyTargetLogin() {
    final parentPostId = widget.post.postId;
    if (parentPostId == null) {
      return;
    }

    final cachedLogin = _replyTargetLoginCache[parentPostId];
    if (cachedLogin != null) {
      _replyTargetLogin = cachedLogin;
      return;
    }

    _loadReplyTargetLogin(parentPostId);
  }

  Future<void> _loadReplyTargetLogin(int parentPostId) async {
    try {
      final response = await ApiService.getPost(parentPostId, widget.sessionToken);
      if (response.statusCode != 200) {
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final login = (body['user_login'] ?? '').toString().trim();
      if (login.isEmpty) {
        return;
      }

      _replyTargetLoginCache[parentPostId] = login;

      if (!mounted) {
        return;
      }

      setState(() {
        _replyTargetLogin = login;
      });
    } catch (_) {
      // Ignore reply target failures and keep fallback label.
    }
  }

  Future<void> _loadLikes() async {
    try {
      final response = await ApiService.listLikes(
        widget.post.id,
        widget.sessionToken,
      );

      if (response.statusCode != 200) {
        return;
      }

      final likes = (jsonDecode(response.body) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();

      int? currentLikeId;
      for (final like in likes) {
        if (like['user_login'] == widget.currentUserLogin) {
          currentLikeId = like['id'] as int?;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _likes = likes.length;
        _likeId = currentLikeId;
        _liked = currentLikeId != null;
        _isLoadingLikes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingLikes = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_isSubmittingLike) return;

    setState(() => _isSubmittingLike = true);

    try {
      if (_liked && _likeId != null) {
        final response = await ApiService.unlikePost(
          widget.post.id,
          _likeId!,
          widget.sessionToken,
        );

        if (response.statusCode == 204 && mounted) {
          setState(() {
            _liked = false;
            _likes = _likes > 0 ? _likes - 1 : 0;
            _likeId = null;
          });
        }
      } else {
        final response = await ApiService.likePost(
          widget.post.id,
          widget.sessionToken,
        );

        if (response.statusCode == 201 && mounted) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          setState(() {
            _liked = true;
            _likes += 1;
            _likeId = body['id'] as int?;
          });
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel atualizar a curtida'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingLike = false);
      }
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir postagem'),
            content: const Text('Deseja excluir esta postagem?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      final response = await ApiService.deletePost(
        widget.post.id,
        widget.sessionToken,
      );

      if (!mounted) return;

      if (response.statusCode == 204) {
        widget.onDeleted?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postagem excluida')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir postagem: ${response.statusCode}')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel excluir a postagem'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'agora';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    final cleanedLogin = widget.post.userLogin.trim();
    final avatarText = cleanedLogin.isEmpty
        ? '?'
        : cleanedLogin.characters.first.toUpperCase();
    final displayLogin = cleanedLogin.isEmpty ? 'usuario' : cleanedLogin;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.leaf.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.profile,
                  arguments: displayLogin,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.leaf.withValues(alpha: 0.25),
                  child: Text(
                    avatarText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.bark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.profile,
                    arguments: displayLogin,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@$displayLogin',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.bark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _relativeDate(widget.post.createdAt),
                        style: TextStyle(
                          color: AppColors.moss.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.isOwner)
                IconButton(
                  onPressed: _deletePost,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Excluir postagem',
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.post.postId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _replyTargetLogin == null || _replyTargetLogin!.isEmpty
                    ? 'Respondendo...'
                    : 'Respondendo à @$_replyTargetLogin',
                style: TextStyle(
                  color: AppColors.moss.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ),
          Text(
            widget.post.message,
            style: const TextStyle(
              color: AppColors.bark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: _isLoadingLikes || _isSubmittingLike ? null : _toggleLike,
                icon: Icon(
                  _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _liked ? AppColors.sun : AppColors.moss,
                  size: 18,
                ),
              ),
              Text(
                _isLoadingLikes ? '...' : '$_likes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _liked ? AppColors.sun : AppColors.moss,
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: widget.onReply,
                icon: const Icon(Icons.mode_comment_outlined, size: 18),
                label: const Text('Responder'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
