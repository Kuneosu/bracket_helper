import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/core/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
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
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 언어 변경을 감지하기 위한 값
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    // 초기 언어 설정
    _currentLanguage = LanguageService.languageChangeNotifier.value;
    
    // 언어 변경 리스너 등록
    LanguageService.languageChangeNotifier.addListener(_onLanguageChanged);
  }
  
  @override
  void dispose() {
    // 리스너 제거
    LanguageService.languageChangeNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }
  
  // 언어 변경 시 UI 갱신
  void _onLanguageChanged() {
    setState(() {
      _currentLanguage = LanguageService.languageChangeNotifier.value;
      debugPrint('MainScreen: 언어가 변경되었습니다: $_currentLanguage');
    });
  }

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
          child: widget.body,
        ),
        bottomNavigationBar: NavigationBar(
          indicatorColor: Colors.transparent,
          backgroundColor: CST.white,
          onDestinationSelected: widget.onChangeIndex,
          selectedIndex: widget.currentPageIndex,
          height: 60,

          labelTextStyle: WidgetStateProperty.all(
            TST.smallTextRegular.copyWith(
              color: CST.black,
              fontSize: 12,
              overflow: TextOverflow.visible,
            ),
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
              label: AppStrings.shortGroupManagement,
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
