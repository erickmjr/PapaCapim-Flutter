import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/models/user_model.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/screens/feed.dart';
import 'package:papa_capim/services/secure_token.dart';
import 'package:papa_capim/theme.dart';
import 'package:provider/provider.dart' show ReadContext;
import '../services/api_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _loginController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndLogin() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await ApiService.post(
        "/sessions",
        body: {
          "login": login,
          "password": password,
        },
      );

      if (!mounted) return; 
      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final user = UserModel.fromJson(data);

        await SecureStorageService.saveUser(user);

        if (!mounted) return;
        context.read<UserProvider>().setUser(user);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FeedScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifique suas credenciais e tente novamente'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.leaf.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.eco_rounded,
                    size: 56,
                    color: AppColors.forest,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Papacapim',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forest,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Login'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _loginController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(hintText: 'Username'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Senha'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: '********'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _validateAndLogin,
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text('Criar conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
