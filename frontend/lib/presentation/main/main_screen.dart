import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.body,
    required this.currentPageIndex,
    required this.onChangeIndex,
  });

  final Widget body;
  final int currentPageIndex;
  final Function(int) onChangeIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.transparent,
        backgroundColor: CST.white,
        onDestinationSelected: onChangeIndex,
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: CST.primary100),
            icon: Icon(Icons.home, color: CST.gray3),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings, color: CST.primary100),
            icon: Icon(Icons.settings, color: CST.gray3),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
