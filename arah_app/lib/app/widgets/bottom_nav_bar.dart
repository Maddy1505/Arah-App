import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/orders/my_orders_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/profile/user_profile_screen.dart';
import 'package:flutter/cupertino.dart';

class ArahBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const ArahBottomNavBar({super.key, required this.currentIndex});

  void _navigate(int index, BuildContext context) {
    if (index == currentIndex) return;

    if (index == 0) {
      // Return to root (Home)
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    Widget screen;
    switch (index) {
      case 1:
        screen = const MyOrdersScreen();
        break;
      case 2:
        screen = const ChatScreen();
        break;
      case 3:
        screen = const UserProfileScreen();
        break;
      default:
        return;
    }

    if (currentIndex == 0) {
      // Navigating from Home to a new tab: push onto stack
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } else {
      // Navigating between non-home tabs: replace to avoid infinite stack
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigate(index, context),
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF6A4BFF), // Purple
      unselectedItemColor: Colors.blueGrey.shade300,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Icon(CupertinoIcons.house, size: 26),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Icon(CupertinoIcons.house_fill, size: 26),
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Icon(Icons.assignment_outlined, size: 26),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Icon(Icons.assignment, size: 26),
          ),
          label: "Orders",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Icon(CupertinoIcons.chat_bubble, size: 26),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Icon(CupertinoIcons.chat_bubble_fill, size: 26),
          ),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Icon(CupertinoIcons.person, size: 26),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Icon(CupertinoIcons.person_solid, size: 26),
          ),
          label: "Profile",
        ),
      ],
    );
  }
}
