import 'package:flutter/material.dart';
import 'package:papa_capim/models/post_model.dart';
import 'package:papa_capim/providers/user_provider.dart';
import 'package:papa_capim/services/api_services.dart';
import 'package:papa_capim/theme.dart';
import 'package:papa_capim/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({
    super.key,
    this.replyToPost,
  });

  final PostModel? replyToPost;

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxChars = 280;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final message = _controller.text.trim();
    final user = context.read<UserProvider>().user;

    if (message.isEmpty || user?.token == null) return;

    setState(() => _isSubmitting = true);

    try {
      final response = widget.replyToPost == null
          ? await ApiService.createPost(message, user!.token!)
          : await ApiService.replyToPost(
              widget.replyToPost!.id,
              message,
              user!.token!,
            );

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao publicar: ${response.statusCode}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel publicar agora'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final displayName = user?.userName.isNotEmpty == true
        ? user!.userName
        : (user?.userLogin ?? 'Usuario');
    final title = widget.replyToPost == null ? 'Nova postagem' : 'Responder';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.forest,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _publish,
            style: TextButton.styleFrom(foregroundColor: AppColors.cream),
            child: Text(_isSubmitting ? 'Enviando...' : 'Publicar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.replyToPost != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '@${widget.replyToPost!.userLogin}: ${widget.replyToPost!.message}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.bark),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  name: displayName,
                  color: AppColors.forest,
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
          ],
        ),
      ),
    );
  }
}
