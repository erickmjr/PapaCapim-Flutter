import 'package:flutter/material.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/theme.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Field(label: 'Nome completo', hint: 'Joao da Silva'),
          const SizedBox(height: 12),
          const _Field(label: 'Usuario', hint: '@joaosilva'),
          const SizedBox(height: 12),
          const _Field(
            label: 'Email',
            hint: 'joao@exemplo.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          const _Field(
            label: 'Senha',
            hint: '********',
            obscureText: true,
          ),
          const SizedBox(height: 12),
          const _Field(
            label: 'Confirmar senha',
            hint: '********',
            obscureText: true,
          ),
          const SizedBox(height: 12),
          const _Field(
            label: 'Bio',
            hint: 'Conte um pouco sobre voce...',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.feed),
            child: const Text('Criar conta'),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.bark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
