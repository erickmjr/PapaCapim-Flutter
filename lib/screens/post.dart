import 'package:flutter/material.dart';
import 'package:papa_capim/data/mock_data.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/user_avatar.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxChars = 280;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _publish() {
    if (_controller.text.trim().isEmpty) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = USERS[currentUserId]!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova postagem'),
        backgroundColor: AppColors.cream,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _publish,
            child: const Text('Publicar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              name: user.name,
              color: user.avatarColor,
              size: AvatarSize.md,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLength: _maxChars,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'O que esta acontecendo?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
