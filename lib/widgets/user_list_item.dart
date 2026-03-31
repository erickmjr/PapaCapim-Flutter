import 'package:flutter/material.dart';
import 'package:papa_capim/models/user_model.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/user_avatar.dart';

class UserListItem extends StatelessWidget {
  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    this.padding = const EdgeInsets.all(12),
  });

  final UserModel user;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cleanedName = user.userName.trim();
    final cleanedLogin = user.userLogin.trim();
    final avatarName = cleanedName.isNotEmpty
        ? cleanedName
        : (cleanedLogin.isNotEmpty ? cleanedLogin : 'Usuário');
    final displayName = cleanedName.isNotEmpty
        ? cleanedName
        : (cleanedLogin.isNotEmpty ? cleanedLogin : 'Usuário');
    final displayLogin = cleanedLogin.isNotEmpty
        ? cleanedLogin
        : 'indisponivel';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              UserAvatar(
                name: avatarName,
                color: AppColors.forest,
                size: AvatarSize.md,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.bark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@$displayLogin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.moss),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.moss),
            ],
          ),
        ),
      ),
    );
  }
}
