import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/app.dart';
import 'package:papa_capim/models/post_model.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/screens/post.dart';
import 'package:papa_capim/screens/search_posts.dart';
import 'package:papa_capim/screens/search_users.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/services/secure_token.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/api_post_card.dart';
import 'package:papa_capim/widgets/bottom_tab_bar.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with RouteAware {
  bool _isRouteSubscribed = false;
  List<PostModel> _posts = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isRouteSubscribed) return;

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _isRouteSubscribed = true;
    }
  }

  @override
  void dispose() {
    if (_isRouteSubscribed) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadFeed(refreshing: true);
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

      final response = await ApiService.listPosts(
        feedOnly: true,
        sessionToken: token,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _posts = PostModel.fromList(jsonDecode(response.body) as List<dynamic>);
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

  Future<void> _openReply(PostModel post) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NewPostScreen(replyToPost: post),
      ),
    );

    if (created == true && mounted) {
      _loadFeed();
    }
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (mounted) {
      _loadFeed(refreshing: true);
    }
  }

  Widget _buildBody() {
    final currentUser = context.watch<UserProvider>().user;

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
                  style: TextStyle(color: AppColors.moss.withValues(alpha: 0.8)),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                ..._posts.map(
                  (post) => ApiPostCard(
                    post: post,
                    sessionToken: currentUser?.token ?? '',
                    currentUserLogin: currentUser?.userLogin ?? '',
                    isOwner: currentUser?.userLogin == post.userLogin,
                    onReply: () => _openReply(post),
                    onDeleted: _loadFeed,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 120),
                  child: Text(
                    'Isso é tudo por enquanto',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.moss.withValues(alpha: 0.6)),
                  ),
                ),
              ],
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
        actions: [
          IconButton(
            tooltip: 'Buscar usuários',
            onPressed: () => _openScreen(const SearchUsersScreen()),
            icon: const Icon(Icons.person_search_outlined),
          ),
          IconButton(
            tooltip: 'Buscar postagens',
            onPressed: () => _openScreen(const SearchPostsScreen()),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}

class _FeedAuthException implements Exception {
  const _FeedAuthException();
}
