import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/models/user_model.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/services/secure_token.dart';
import 'package:papa_capim/theme.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _loginController;
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _loginController = TextEditingController(text: user?.userLogin ?? '');
    _nameController = TextEditingController(text: user?.userName ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<UserModel?> _resolveEditableUser(UserModel? currentUser) async {
    if (currentUser == null ||
        currentUser.token == null ||
        currentUser.token!.isEmpty ||
        currentUser.userLogin.isEmpty) {
      return null;
    }

    if (currentUser.id != null) {
      return currentUser;
    }

    final response = await ApiService.getUser(
      currentUser.userLogin,
      currentUser.token!,
    );

    if (response.statusCode != 200) {
      return null;
    }

    final refreshedUser = UserModel.fromUserJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    ).copyWith(
      sessionId: currentUser.sessionId,
      token: currentUser.token,
      ip: currentUser.ip,
    );

    await SecureStorageService.saveUser(refreshedUser);
    if (!mounted) return null;
    context.read<UserProvider>().setUser(refreshedUser);
    return refreshedUser;
  }

  Future<void> _save() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.user;
    final login = _loginController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentUser == null ||
        currentUser.token == null ||
        currentUser.token!.isEmpty ||
        currentUser.userLogin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario nao carregado'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (login.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login e nome sao obrigatorios'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (password.isNotEmpty && password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas nao coincidem'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final editableUser = await _resolveEditableUser(currentUser);
    if (!mounted) return;

    if (editableUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario nao carregado'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final payload = <String, dynamic>{};
    if (login != editableUser.userLogin) payload['login'] = login;
    if (name != editableUser.userName) payload['name'] = name;
    if (password.isNotEmpty) {
      payload['password'] = password;
      payload['password_confirmation'] = confirmPassword;
    }

    if (payload.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await ApiService.updateUser(
        editableUser.userLogin,
        payload,
        editableUser.token!,
      );

      if (!mounted) return;

      if (response.statusCode != 200 && response.statusCode != 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: ${response.statusCode}'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final updatedUser = editableUser.copyWith(
        id: body['id'] as int?,
        userLogin: body['login'] as String? ?? editableUser.userLogin,
        userName: body['name'] as String? ?? editableUser.userName,
        updatedAt: DateTime.now(),
      );

      if (password.isNotEmpty) {
        await SecureStorageService.clearUser();
        userProvider.clearUser();

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );
        return;
      }

      await SecureStorageService.saveUser(updatedUser);
      userProvider.setUser(updatedUser);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel atualizar o perfil'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            style: TextButton.styleFrom(foregroundColor: AppColors.cream),
            child: Text(_isSaving ? 'Salvando...' : 'Salvar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Field(label: 'Login', controller: _loginController),
          const SizedBox(height: 16),
          _Field(label: 'Nome', controller: _nameController),
          const SizedBox(height: 16),
          _Field(
            label: 'Nova senha (opcional)',
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          _Field(
            label: 'Confirmar senha',
            controller: _confirmPasswordController,
            obscureText: true,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;

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
          controller: controller,
          obscureText: obscureText,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
