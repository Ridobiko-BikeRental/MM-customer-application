import 'package:flutter/material.dart';
import '../app_colors.dart';

class MainNavBar extends StatelessWidget {
  final int currentIndex;
  const MainNavBar({super.key, required this.currentIndex});

  void navigateTo(BuildContext context, int index) {
    String targetRoute = '/home_screen';
    switch (index) {
      case 0:
        targetRoute = '/home_screen';
        break;
      case 1:
        targetRoute = '/mealbox_screen';
        break;
      case 2:
        targetRoute = '/favourite';
        break;
      case 3:
        targetRoute = '/history';
        break;
      case 4:
        targetRoute = '/help';
        break;
    }
    if (ModalRoute.of(context)?.settings.name != targetRoute) {
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: AppColors.primary,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey.shade400,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (int idx) => navigateTo(context, idx),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        //BottomNavigationBarItem(icon: Icon(Icons.room_service), label: ''), 
        BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: ''),
      ],
    );
  }
}
