import 'package:flutter/material.dart';
import 'package:papa_capim/data/mock_data.dart';
import 'package:papa_capim/models/user.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/bottom_tab_bar.dart';
import 'package:papa_capim/widgets/post_card.dart';
import 'package:papa_capim/widgets/user_avatar.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, this.username});

  final String? username;

  @override
  Widget build(BuildContext context) {
    final user = USERS.values.firstWhere(
      (u) => u.username == (username ?? USERS[currentUserId]!.username),
      orElse: () => USERS[currentUserId]!,
    );
    final isOwnProfile = user.id == currentUserId;
    final userPosts = POSTS.where((post) => post.userId == user.id).toList();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatar(
                name: user.name,
                color: user.avatarColor,
                size: AvatarSize.lg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileHeader(user: user),
              ),
              if (isOwnProfile)
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.profileEdit),
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user.bio, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBlock(label: 'Seguindo', value: user.following),
              const SizedBox(width: 16),
              _StatBlock(label: 'Seguidores', value: user.followers),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Publicacoes',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (userPosts.isEmpty)
            Text(
              'Nenhuma publicacao ainda.',
              style: TextStyle(color: AppColors.moss.withOpacity(0.7)),
            )
          else
            ...userPosts.map((post) {
              final postUser = USERS[post.userId] ?? user;
              return PostCard(
                post: post,
                user: postUser,
                isOwner: isOwnProfile,
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
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.bark,
          ),
        ),
        Text('@${user.username}',
            style: const TextStyle(color: AppColors.moss)),
        if (user.location != null)
          Text(
            user.location!,
            style: const TextStyle(color: AppColors.moss, fontSize: 12),
          ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.bark,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.moss)),
      ],
    );
  }
}
