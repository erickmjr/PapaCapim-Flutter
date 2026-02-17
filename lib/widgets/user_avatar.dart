import 'package:flutter/material.dart';
import 'package:papa_capim/theme.dart';

enum AvatarSize { sm, md, lg, xl }

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = AvatarSize.md,
    this.imageUrl,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String name;
  final Color color;
  final AvatarSize size;
  final String? imageUrl;
  final Color? borderColor;
  final double borderWidth;

  double get _dimension {
    switch (size) {
      case AvatarSize.sm:
        return 32;
      case AvatarSize.md:
        return 40;
      case AvatarSize.lg:
        return 64;
      case AvatarSize.xl:
        return 96;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.sm:
        return 12;
      case AvatarSize.md:
        return 14;
      case AvatarSize.lg:
        return 22;
      case AvatarSize.xl:
        return 30;
    }
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _dimension,
      height: _dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: borderWidth > 0
            ? Border.all(color: borderColor ?? AppColors.cream, width: borderWidth)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl == null
            ? Center(
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: _fontSize,
                  ),
                ),
              )
            : Image.network(imageUrl!, fit: BoxFit.cover),
      ),
    );
  }
}
