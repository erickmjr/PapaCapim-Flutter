import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/services/secure_token.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/bottom_tab_bar.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<_FeedPost> _posts = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed({bool refreshing = false}) async {
    if (!refreshing) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw const _FeedAuthException();
      }

      final response = await ApiService.get(
        '/posts',
        queryParameters: const {
          'feed': '1',
          'page': '1',
        },
        sessionToken: token,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! List) {
          throw const FormatException('Resposta inválida do feed');
        }

        final posts = decoded
            .whereType<Map<String, dynamic>>()
            .map(_FeedPost.fromJson)
            .toList();

        if (!mounted) return;
        setState(() {
          _posts = posts;
          _isLoading = false;
          _errorMessage = null;
        });
        return;
      }

      if (response.statusCode == 401) {
        await SecureStorageService.clearUser();
        throw const _FeedAuthException();
      }

      throw Exception('Erro ao carregar feed: ${response.statusCode}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _posts = const [];
        _isLoading = false;
        _errorMessage = e is _FeedAuthException
            ? 'Sessão expirada. Faça login novamente.'
            : 'Não foi possível carregar o feed.';
      });
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.bark),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadFeed,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadFeed(refreshing: true),
      child: _posts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                const SizedBox(height: 160),
                Text(
                  'Nenhuma publicação no seu feed por enquanto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.moss.withOpacity(0.8)),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _posts.length + 1,
              itemBuilder: (context, index) {
                if (index == _posts.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 120),
                    child: Text(
                      'Isso é tudo por enquanto',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.moss.withOpacity(0.6)),
                    ),
                  );
                }

                final post = _posts[index];
                final avatarText = post.userLogin.isEmpty
                    ? '?'
                    : post.userLogin[0].toUpperCase();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.leaf.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.leaf.withOpacity(0.25),
                            child: Text(
                              avatarText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.bark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@${post.userLogin}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.bark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _relativeDate(post.createdAt),
                                  style: TextStyle(
                                    color: AppColors.moss.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (post.postId != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Resposta ao post #${post.postId}',
                            style: TextStyle(
                              color: AppColors.moss.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Text(
                        post.message,
                        style: const TextStyle(
                          color: AppColors.bark,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Papacapim',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: const Icon(Icons.eco_rounded, color: AppColors.cream),
        backgroundColor: AppColors.forest,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}

class _FeedPost {
  final int id;
  final String userLogin;
  final int? postId;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;

  const _FeedPost({
    required this.id,
    required this.userLogin,
    required this.postId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _FeedPost.fromJson(Map<String, dynamic> json) {
    return _FeedPost(
      id: json['id'] as int,
      userLogin: (json['user_login'] ?? '') as String,
      postId: json['post_id'] as int?,
      message: (json['message'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class _FeedAuthException implements Exception {
  const _FeedAuthException();
}
