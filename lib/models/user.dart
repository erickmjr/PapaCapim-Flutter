import 'package:flutter/material.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.avatarColor,
    required this.followers,
    required this.following,
    required this.postsCount,
    this.location,
  });

  final String id;
  final String name;
  final String username;
  final String bio;
  final Color avatarColor;
  final int followers;
  final int following;
  final int postsCount;
  final String? location;
}
