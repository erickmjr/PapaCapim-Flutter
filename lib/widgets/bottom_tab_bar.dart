import 'package:flutter/material.dart';
import 'package:papa_capim/routes.dart';
import 'package:papa_capim/theme.dart';

class BottomTabBar extends StatelessWidget {
  const BottomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';
    final index = _currentIndex(route);

    return BottomNavigationBar(
      currentIndex: index,
      onTap: (value) {
        switch (value) {
          case 0:
            _navigate(context, AppRoutes.feed);
            break;
          case 1:
            _navigate(context, AppRoutes.newPost);
            break;
          case 2:
            _navigate(context, AppRoutes.profile);
            break;
        }
      },
      selectedItemColor: AppColors.forest,
      unselectedItemColor: AppColors.moss,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline_rounded),
          label: 'Postar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }

  int _currentIndex(String route) {
    if (route == AppRoutes.feed) return 0;
    if (route == AppRoutes.newPost) return 1;
    if (route == AppRoutes.profile || route == AppRoutes.profileEdit) return 2;
    return 0;
  }

  void _navigate(BuildContext context, String route) {
    final current = ModalRoute.of(context)?.settings.name ?? '';
    if (current == route) return;
    Navigator.pushNamed(context, route);
  }
}
