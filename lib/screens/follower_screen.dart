// lib/screens/followers_screen.dart
import 'package:flutter/material.dart';
import 'package:papa_capim/screens/profile.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/user_avatar.dart';
import 'package:papa_capim/models/user_model.dart';

class FollowersScreen extends StatelessWidget {
  final List<UserModel> followers;
  final String userLogin;

  const FollowersScreen({
    super.key,
    required this.followers,
    required this.userLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguidores de $userLogin:'),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: followers.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: followers.length,
              itemBuilder: (context, index) {
                final follower = followers[index];
                return _buildFollowerTile(follower, context);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.moss.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum seguidor ainda',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.moss.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowerTile(UserModel follower, BuildContext context) {

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: UserAvatar(
          name: follower.userLogin, 
          color: Colors.green,
          size: AvatarSize.md,
        ),
        title: Text(
          follower.userLogin, 
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.bark,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.moss,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                user: follower,
              ),
            ),
          );
        },
      ),
    );
  }
}