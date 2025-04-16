import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
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
      body: Container(
        decoration: BoxDecoration(
          color: CST.white,
          border: Border(bottom: BorderSide(color: CST.gray4)),
        ),
        child: body,
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.transparent,
        backgroundColor: CST.white,
        onDestinationSelected: onChangeIndex,
        selectedIndex: currentPageIndex,

        labelTextStyle: WidgetStateProperty.all(
          TST.smallTextRegular.copyWith(color: CST.black),
        ),
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: CST.primary100),
            icon: Icon(Icons.home, color: CST.gray3),
            label: '홈',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person, color: CST.primary100),
            icon: Icon(Icons.person, color: CST.gray3),
            label: '선수 목록',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings, color: CST.primary100),
            icon: Icon(Icons.settings, color: CST.gray3),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
