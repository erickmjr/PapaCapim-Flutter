import 'package:flutter/material.dart';
import 'package:papa_capim/data/mock_data.dart';
import 'package:papa_capim/models/post.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/bottom_tab_bar.dart';
import 'package:papa_capim/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late List<Post> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List.of(POSTS);
  }

  void _deletePost(String id) {
    setState(() {
      _posts.removeWhere((post) => post.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Postagem excluida')),
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
        leading: const Icon(Icons.eco_rounded, color: AppColors.forest),
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 120),
              child: Text(
                'Isso e tudo por enquanto',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.moss.withOpacity(0.6)),
              ),
            );
          }

          final post = _posts[index];
          final user = USERS[post.userId];
          if (user == null) return const SizedBox.shrink();
          return PostCard(
            post: post,
            user: user,
            isOwner: post.userId == currentUserId,
            onDelete:
                post.userId == currentUserId ? () => _deletePost(post.id) : null,
            onReply: () => Navigator.pushNamed(context, AppRoutes.newPost),
          );
        },
      ),
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}
