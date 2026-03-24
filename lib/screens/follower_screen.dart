import 'package:flutter/material.dart';
import 'package:papa_capim/models/user_model.dart';
import 'package:papa_capim/screens/profile.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/user_list_item.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({
    super.key,
    required this.users,
    required this.title,
    required this.emptyMessage,
  });

  final List<UserModel> users;
  final String title;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: users.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserTile(user, context);
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
            color: AppColors.moss.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.moss.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: UserListItem(
        user: user,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(
                userLogin: user.userLogin,
              ),
            ),
          );
        },
      ),
    );
  }
}
