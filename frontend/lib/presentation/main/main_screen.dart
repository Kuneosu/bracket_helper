import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.exit_to_app, color: CST.primary100),
              const SizedBox(width: 8),
              Text(
                '앱 종료',
                style: TST.mediumTextBold.copyWith(color: CST.primary100),
              ),
            ],
          ),
          content: Text('앱을 종료하시겠습니까?', style: TST.normalTextRegular),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: CST.gray4,
                foregroundColor: CST.gray1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(100, 40),
              ),
              child: Text('취소', style: TST.normalTextBold),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CST.primary100,
                foregroundColor: CST.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(100, 40),
              ),
              child: Text('종료', style: TST.normalTextBold),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(context);
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
              label: '그룹 관리',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings, color: CST.primary100),
              icon: Icon(Icons.settings, color: CST.gray3),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}
