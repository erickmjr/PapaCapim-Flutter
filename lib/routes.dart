import 'package:flutter/material.dart';
import 'package:papa_capim/models/post_model.dart';
import 'package:papa_capim/screens/edit_profile.dart';
import 'package:papa_capim/screens/feed.dart';
import 'package:papa_capim/screens/login.dart';
import 'package:papa_capim/screens/post.dart';
import 'package:papa_capim/screens/profile.dart';
import 'package:papa_capim/screens/search_posts.dart';
import 'package:papa_capim/screens/search_users.dart';
import 'package:papa_capim/screens/signup.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const feed = '/feed';
  static const newPost = '/new-post';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const searchUsers = '/search/users';
  static const searchPosts = '/search/posts';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? login;
    final args = settings.arguments;

    Widget page;
    switch (routeName) {
      case login:
      case '/':
        page = const LoginScreen();
        break;
      case register:
        page = const RegisterScreen();
        break;
      case feed:
        page = const FeedScreen();
        break;
      case newPost:
        page = NewPostScreen(
          replyToPost: args is PostModel ? args : null,
        );
        break;
      case profile:
        page = UserProfileScreen(
          userLogin: args is String ? args : null,
        );
        break;
      case profileEdit:
        page = const EditProfileScreen();
        break;
      case searchUsers:
        page = const SearchUsersScreen();
        break;
      case searchPosts:
        page = const SearchPostsScreen();
        break;
      default:
        page = const LoginScreen();
    }

    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
