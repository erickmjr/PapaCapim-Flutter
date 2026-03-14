// lib/screens/user_profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:papa_capim/screens/follower_screen.dart';
import 'package:provider/provider.dart';

import 'package:papa_capim/data/mock_data.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/bottom_tab_bar.dart';
import 'package:papa_capim/widgets/post_card.dart';
import 'package:papa_capim/widgets/user_avatar.dart';
import 'package:papa_capim/screens/login.dart';

import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/models/user_model.dart';
import 'package:papa_capim/services/api_services.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel? user;

  const UserProfileScreen({
    super.key,
    this.user,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

// lib/screens/user_profile_screen.dart
class _UserProfileScreenState extends State<UserProfileScreen> {
  List<UserModel> _followers = [];
  bool _isLoadingFollowers = false;
  bool _isFollowing = false;
  bool _isFollowLoading = false; // NOVO: estado para loading do botão

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final String targetLogin = widget.user?.userLogin ?? 
                              userProvider.user?.userLogin ?? 
                              '';
    
    if (targetLogin.isEmpty) return;

    setState(() => _isLoadingFollowers = true);

    try {
      final token = userProvider.token;
      
      if (token == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const LoginScreen())
          );
        }
        return;
      }

      final response = await ApiService.get(
        "/users/$targetLogin/followers", 
        sessionToken: token
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final followers = UserModel.fromFollowersList(jsonList);
        
        setState(() {
          _followers = followers;
          _isFollowing = followers.any((follower) => 
            follower.userLogin == userProvider.user?.userLogin
          );
        });
      } else {
        throw Exception('Failed to load followers');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar seguidores'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingFollowers = false);
      }
    }
  }

  Future<void> _followUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    
    if (currentUser?.token == null) return;

    setState(() {
      _isFollowing = true;
      _isFollowLoading = true; // Ativa loading
    });

    try {
      final response = await ApiService.follow(
        widget.user!.userLogin,
        currentUser!.token!,
      );
      
      if (response != null && response.statusCode == 201) {
        setState(() {
          _followers.insert(0, UserModel(
            userLogin: currentUser.userLogin,
            userName: currentUser.userName,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
          _isFollowLoading = false; // Desativa loading
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Você está seguindo @${widget.user!.userLogin}'),
              backgroundColor: AppColors.leaf,
            ),
          );
        }
      } else {
        setState(() {
          _isFollowing = false;
          _isFollowLoading = false; // Desativa loading
        });
      }
    } catch (e) {
      setState(() {
        _isFollowing = false;
        _isFollowLoading = false; // Desativa loading
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao seguir usuário'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unfollowUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    
    if (currentUser?.token == null) return;

    setState(() {
      _isFollowing = false;
      _isFollowLoading = true; // Ativa loading
    });

    try {
      final response = await ApiService.unfollow(
        widget.user!.userLogin,
        currentUser!.token!,
      );
      
      if (response != null && response.statusCode == 204) {
        setState(() {
          _followers.removeWhere((follower) => 
            follower.userLogin == currentUser.userLogin
          );
          _isFollowLoading = false; // Desativa loading
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Você deixou de seguir @${widget.user!.userLogin}'),
              backgroundColor: AppColors.sun,
            ),
          );
        }
      } else {
        setState(() {
          _isFollowing = true;
          _isFollowLoading = false; // Desativa loading
        });
      }
    } catch (e) {
      setState(() {
        _isFollowing = true;
        _isFollowLoading = false; // Desativa loading
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deixar de seguir'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    final displayUser = widget.user ?? userProvider.user;
    final currentUser = userProvider.user;
    
    if (displayUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isOwnProfile = currentUser?.userLogin == displayUser.userLogin;
    final avatarName = displayUser.userName.isNotEmpty ? displayUser.userName : displayUser.userLogin;
    final userPosts = POSTS.where((post) => post.userId == displayUser.userId).toList();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(isOwnProfile ? 'Perfil' : displayUser.userName),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        elevation: 0,
        actions: [
          if (isOwnProfile)
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.profileEdit),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatar(
                name: avatarName,
                color: Colors.green,
                size: AvatarSize.lg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileHeader(
                  userLogin: displayUser.userLogin,
                ),
              ),
              if (!isOwnProfile) ...[
                const SizedBox(width: 8),
                _FollowButton(
                  isFollowing: _isFollowing,
                  isLoading: _isLoadingFollowers || _isFollowLoading, // Desabilitado enquanto carrega
                  onPressed: (_isLoadingFollowers || _isFollowLoading) 
                      ? null 
                      : (_isFollowing ? _unfollowUser : _followUser),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Seção de seguidores clicável
          GestureDetector(
            onTap: _followers.isNotEmpty ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersScreen(
                    followers: _followers,
                    userLogin: displayUser.userLogin,
                  ),
                ),
              );
            } : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.leaf.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seguidores',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.bark,
                    ),
                  ),
                  Row(
                    children: [
                      if (_isLoadingFollowers)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.forest,
                          ),
                        )
                      else
                        Text(
                          '${_followers.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forest,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _followers.isNotEmpty 
                            ? AppColors.moss 
                            : AppColors.moss.withOpacity(0.3),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                isOwner: isOwnProfile,
              );
            }),

          const SizedBox(height: 120),
        ],
      ),
      bottomNavigationBar: isOwnProfile ? const BottomTabBar() : null,
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _FollowButton({
    required this.isFollowing,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? AppColors.cream : AppColors.forest,
        foregroundColor: isFollowing ? AppColors.forest : AppColors.cream,
        side: BorderSide(
          color: isFollowing ? AppColors.forest : Colors.transparent,
        ),
        minimumSize: const Size(80, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFollowing ? AppColors.forest : AppColors.cream,
                ),
              ),
            )
          : Text(isFollowing ? 'Seguindo' : 'Seguir'),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String userLogin;

  const _ProfileHeader({
    required this.userLogin,
  });

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
      ],
    );
  }
}
