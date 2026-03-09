import 'package:flutter/material.dart';
import 'package:papa_capim/app.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const PapaCapimApp(),
    ),
  );
}
