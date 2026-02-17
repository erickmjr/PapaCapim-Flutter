import 'package:flutter/material.dart';
import 'package:papa_capim/screens/edit_profile.dart';
import 'package:papa_capim/screens/feed.dart';
import 'package:papa_capim/screens/login.dart';
import 'package:papa_capim/screens/post.dart';
import 'package:papa_capim/screens/profile.dart';
import 'package:papa_capim/screens/signup.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const feed = '/feed';
  static const newPost = '/new-post';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? login;
    final usernameArg = settings.arguments is String
        ? settings.arguments as String
        : null;

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
        page = const NewPostScreen();
        break;
      case profile:
        page = UserProfileScreen(username: usernameArg);
        break;
      case profileEdit:
        page = const EditProfileScreen();
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
