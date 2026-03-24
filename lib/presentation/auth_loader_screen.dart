import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/screens/feed.dart';
import 'package:papa_capim/screens/login.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/services/secure_token.dart';
import 'package:provider/provider.dart';

class AuthLoaderScreen extends StatefulWidget {
  const AuthLoaderScreen({super.key});

  @override
  State<AuthLoaderScreen> createState() => _AuthLoaderScreenState();
}

class _AuthLoaderScreenState extends State<AuthLoaderScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final storedUser = await SecureStorageService.getUser();
    if (!mounted) return;
    final userProvider = context.read<UserProvider>();

    if (storedUser == null || storedUser.token == null || storedUser.token!.isEmpty) {
      _goLogin();
      return;
    }

    try {
      final response = await ApiService.getUser(
        storedUser.userLogin,
        storedUser.token!,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final refreshedUser = storedUser.copyWith(
          id: body['id'] as int?,
          userName: body['name'] as String? ?? storedUser.userName,
        );
        await SecureStorageService.saveUser(refreshedUser);
        if (!mounted) return;
        userProvider.setUser(refreshedUser);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FeedScreen()),
        );
        return;
      }
    } catch (_) {
      // falls through to login
    }

    await SecureStorageService.clearUser();
    _goLogin();
  }

  void _goLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
