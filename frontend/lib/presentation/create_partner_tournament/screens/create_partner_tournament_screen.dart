import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePartnerTournamentScreen extends StatelessWidget {
  final Widget body;
  final int currentPageIndex;
  final VoidCallback? onExit;

  const CreatePartnerTournamentScreen({
    super.key,
    required this.body,
    required this.currentPageIndex,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 첫 번째 화면(기본 정보)에서만 대화상자 표시
        if (currentPageIndex == 0) {
          final shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit && context.mounted) {
            // 종료 콜백 호출
            _dispatchOnDiscardAction();
            // 홈 화면으로 이동
            context.go(RoutePaths.home);
          }
        } else {
          // 다른 페이지에서는 이전 페이지로 이동
          _navigateToPreviousPage(context);
        }
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              children: [Text(AppStrings.createBracketTitle, style: TST.largeTextRegular)],
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                // 첫 번째 화면(기본 정보)에서만 대화상자 표시
                if (currentPageIndex == 0) {
                  final shouldExit = await _showExitConfirmationDialog(context);
                  if (shouldExit && context.mounted) {
                    // 종료 콜백 호출
                    _dispatchOnDiscardAction();
                    context.go(RoutePaths.home);
                  }
                } else {
                  // 다른 페이지에서는 이전 페이지로 이동
                  _navigateToPreviousPage(context);
                }
              },
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildProcessHeader(), Expanded(child: body)],
          ),
        ),
      ),
    );
  }

  Container _buildProcessHeader() {
    final titleList = [
      AppStrings.basicInfo, 
      AppStrings.addPlayers, 
      AppStrings.editBracketTitle
    ];
    final selectedPageIndex = currentPageIndex + 1;
    final selectedCircleColor = CST.white;
    final selectedTextStyle = TST.smallTextBold.copyWith(color: CST.white);
    final selectedNumStyle = TST.mediumTextBold.copyWith(color: CST.primary100);
    final unselectedCircleColor = CST.primary100;
    final unselectedTextStyle = TST.smallTextRegular.copyWith(color: CST.white);
    final unselectedNumStyle = TST.mediumTextRegular.copyWith(color: CST.white);

    return Container(
      color: CST.primary100,
      height: 90,
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
            [1, 2, 3]
                .map(
                  (e) => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              e == selectedPageIndex
                                  ? selectedCircleColor
                                  : unselectedCircleColor,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: CST.white, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            '$e',
                            style:
                                e == selectedPageIndex
                                    ? selectedNumStyle
                                    : unselectedNumStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        titleList[e - 1],
                        style:
                            e == selectedPageIndex
                                ? selectedTextStyle
                                : unselectedTextStyle,
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }

  // 이전 페이지로 이동하는 헬퍼 메서드
  void _navigateToPreviousPage(BuildContext context) {
    if (currentPageIndex == 1) {
      // 선수 추가 화면에서 대회 정보 화면으로 이동
      context.go('${RoutePaths.createTournament}${RoutePaths.tournamentInfo}');
    } else if (currentPageIndex == 2) {
      // 대진표 수정 화면에서 선수 추가 화면으로 이동
      context.go('${RoutePaths.createTournament}${RoutePaths.addPlayer}');
    }
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: CST.primary100,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.exitTournamentCreation,
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.exitTournamentConfirm,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.unsavedChangesWarning,
                  style: TST.smallTextRegular.copyWith(color: CST.gray2),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: CST.white,
                  backgroundColor: CST.gray3,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.cancel, style: TST.smallTextBold),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CST.primary100,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppStrings.exitTournament, style: TST.smallTextBold),
              ),
            ],
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            buttonPadding: EdgeInsets.zero,
          ),
    );

    return result ?? false;
  }

  void _dispatchOnDiscardAction() {
    if (onExit != null) {
      debugPrint('CreatePartnerTournamentScreen - 종료 확인: 종료 콜백 호출');
      onExit!();
    } else {
      debugPrint('CreatePartnerTournamentScreen - 종료 확인: 종료 콜백이 없음');
    }
  }
}
