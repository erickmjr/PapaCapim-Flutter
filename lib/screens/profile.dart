import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papa_capim/data/mock_data.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/bottom_tab_bar.dart';
import 'package:papa_capim/widgets/post_card.dart';
import 'package:papa_capim/widgets/user_avatar.dart';

import 'package:papa_capim/providers/user_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userPosts = POSTS.where((post) => post.userId == user.userId).toList();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatar(
                name: user.userLogin,
                color: Colors.green,
                size: AvatarSize.lg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileHeader(userLogin: user.userLogin),
              ),
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.profileEdit),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          const Text(
            'Publicações',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          if (userPosts.isEmpty)
            Text(
              'Nenhuma publicação ainda.',
              style: TextStyle(color: AppColors.moss.withOpacity(0.7)),
            )
          else
            ...userPosts.map((post) {
              return PostCard(
                post: post,
                user: USERS[post.userId]!,
                isOwner: true,
              );
            }),

          const SizedBox(height: 120),
        ],
      ),
      bottomNavigationBar: const BottomTabBar(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.userLogin});

  final String userLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userLogin,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.bark,
          ),
        ),
        Text(
          '@$userLogin',
          style: const TextStyle(color: AppColors.moss),
        ),
      ],
    );
  }
}