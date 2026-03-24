import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/models/post_model.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/screens/post.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/api_post_card.dart';
import 'package:provider/provider.dart';

class SearchPostsScreen extends StatefulWidget {
  const SearchPostsScreen({super.key});

  @override
  State<SearchPostsScreen> createState() => _SearchPostsScreenState();
}

class _SearchPostsScreenState extends State<SearchPostsScreen> {
  late final TextEditingController _controller;
  List<PostModel> _posts = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    Future.microtask(_searchPosts);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchPosts() async {
    final user = context.read<UserProvider>().user;
    if (user?.token == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.listPosts(
        search: _controller.text.trim().isEmpty ? null : _controller.text.trim(),
        sessionToken: user!.token!,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _posts = PostModel.fromList(jsonDecode(response.body) as List<dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _posts = const [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _posts = const [];
        _isLoading = false;
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
      _searchPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar postagens'),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchPosts(),
                    decoration: const InputDecoration(
                      hintText: 'Buscar por texto',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _searchPosts,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? const Center(child: Text('Nenhuma postagem encontrada'))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: _posts
                            .map(
                              (post) => ApiPostCard(
                                post: post,
                                sessionToken: user?.token ?? '',
                                currentUserLogin: user?.userLogin ?? '',
                                isOwner: user?.userLogin == post.userLogin,
                                onReply: () => _openReply(post),
                                onDeleted: _searchPosts,
                              ),
                            )
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }
}
