import 'package:flutter/material.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/screens/feed.dart';
import 'package:papa_capim/screens/login.dart';
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

    if (storedUser == null) {
      _goLogin();
      return;
    }

    try {

      if(!mounted) return;

      context.read<UserProvider>().setUser(storedUser);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FeedScreen()));

    } catch (e) {
      _goLogin();
    }
  }

  void _goLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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