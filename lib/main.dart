import 'package:flutter/material.dart';
import 'package:papa_capim/app.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:papa_capim/services/secure_token.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await SecureStorageService.getToken();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: PapaCapimApp(token: token),
    ),
  );
}
