import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
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
                AppStrings.exitApp,
                style: TST.mediumTextBold.copyWith(color: CST.primary100),
              ),
            ],
          ),
          content: Text(AppStrings.exitConfirm, style: TST.normalTextRegular),
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
              child: Text(AppStrings.cancel, style: TST.normalTextBold),
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
              child: Text(AppStrings.exit, style: TST.normalTextBold),
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
          destinations: [
            NavigationDestination(
              selectedIcon: const Icon(Icons.home, color: CST.primary100),
              icon: const Icon(Icons.home, color: CST.gray3),
              label: AppStrings.home,
            ),
            NavigationDestination(
              selectedIcon: const Icon(Icons.person, color: CST.primary100),
              icon: const Icon(Icons.person, color: CST.gray3),
              label: AppStrings.groupManagement,
            ),
            NavigationDestination(
              selectedIcon: const Icon(Icons.settings, color: CST.primary100),
              icon: const Icon(Icons.settings, color: CST.gray3),
              label: AppStrings.settings,
            ),
          ],
        ),
      ),
    );
  }
}
