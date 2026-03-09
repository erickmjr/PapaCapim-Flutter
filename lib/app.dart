import 'package:flutter/material.dart';
import 'package:papa_capim/routes.dart';
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
      initialRoute: token != null ? AppRoutes.feed : AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
