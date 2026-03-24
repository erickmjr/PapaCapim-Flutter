import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:papa_capim/models/user_model.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/user_list_item.dart';
import 'package:provider/provider.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  late final TextEditingController _controller;
  List<UserModel> _users = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    Future.microtask(_searchUsers);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchUsers() async {
    final token = context.read<UserProvider>().token;
    if (token == null || token.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.listUsers(
        search: _controller.text.trim().isEmpty ? null : _controller.text.trim(),
        sessionToken: token,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _users = UserModel.fromList(jsonDecode(response.body) as List<dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _users = const [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _users = const [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar usuarios'),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchUsers(),
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _searchUsers,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('Nenhum usuario encontrado'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];

                          return Card(
                            child: UserListItem(
                              user: user,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.profile,
                                arguments: user.userLogin,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
