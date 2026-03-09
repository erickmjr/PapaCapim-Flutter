import 'package:flutter/material.dart';
import 'package:papa_capim/screens/feed.dart';
import 'package:papa_capim/screens/login.dart';
import 'package:papa_capim/theme.dart';

class PapaCapimApp extends StatelessWidget {
  final String? token;

  const PapaCapimApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Papa Capim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: token != null
          ? const FeedScreen()
          : const LoginScreen(),
    );
  }
}
