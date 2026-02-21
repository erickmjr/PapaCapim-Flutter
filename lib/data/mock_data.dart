import 'package:flutter/material.dart';
import 'package:papa_capim/models/post.dart';
import 'package:papa_capim/models/user.dart';
import 'package:papa_capim/theme.dart';

const currentUserId = 'current';

const Map<String, User> USERS = {
  '1': User(
    id: '1',
    name: 'Maria Silva',
    username: 'mariasilva',
    bio: 'Amante de aves e da natureza brasileira.',
    avatarColor: AppColors.forest,
    followers: 1240,
    following: 450,
    postsCount: 87,
    location: 'Minas Gerais, MG',
  ),
  '2': User(
    id: '2',
    name: 'Joao Santos',
    username: 'joaosantos',
    bio: 'Fotografo de vida selvagem. Cerrado e trilhas.',
    avatarColor: AppColors.leaf,
    followers: 3500,
    following: 210,
    postsCount: 342,
    location: 'Goias, GO',
  ),
  currentUserId: User(
    id: currentUserId,
    name: 'Visitante',
    username: 'visitante',
    bio: 'Explorando o mundo do Papacapim.',
    avatarColor: AppColors.forest,
    followers: 0,
    following: 0,
    postsCount: 1,
    location: 'Brasil',
  ),
};

const List<Post> POSTS = [
  Post(
    id: '101',
    userId: '2',
    content:
        'Hoje consegui fotografar um papacapim no alto de uma arvore.',
    timestamp: 'há 2 horas',
    likes: 45,
    replies: 3,
    isLiked: true,
  ),
  Post(
    id: '102',
    userId: '1',
    content:
        'Bom dia! Alguem sabe identificar esse canto? Ouvi no jardim.',
    timestamp: 'há 4 horas',
    likes: 12,
    replies: 8,
    isLiked: false,
  ),
  Post(
    id: '103',
    userId: currentUserId,
    content:
        'Primeiro post no Papacapim! Ansioso para conhecer pessoas.',
    timestamp: 'há 6 horas',
    likes: 4,
    replies: 1,
    isLiked: false,
  ),
];
