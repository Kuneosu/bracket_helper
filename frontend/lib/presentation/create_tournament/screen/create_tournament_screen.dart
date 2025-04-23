import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateTournamentScreen extends StatelessWidget {
  final Widget body;
  final int currentPageIndex;
  final VoidCallback? onExit;

  const CreateTournamentScreen({
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
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [Text('대진표 생성', style: TST.largeTextRegular)],
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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
    );
  }

  Container _buildProcessHeader() {
    final titleList = ['기본 정보', '선수 추가', '대진표 수정'];
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
      padding: EdgeInsets.only(top: 20),
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
                      SizedBox(height: 4),
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
                SizedBox(width: 12),
                Text(
                  '대회 생성 종료',
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '대회 생성을 종료하시겠습니까?',
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
                SizedBox(height: 8),
                Text(
                  '지금까지 입력한 모든 정보는 저장되지 않습니다.',
                  style: TST.smallTextRegular.copyWith(color: CST.gray2),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: CST.white,
                  backgroundColor: CST.gray3,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('취소', style: TST.smallTextBold),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CST.primary100,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('종료하기', style: TST.smallTextBold),
              ),
            ],
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            buttonPadding: EdgeInsets.zero,
          ),
    );

    return result ?? false;
  }

  void _dispatchOnDiscardAction() {
    if (onExit != null) {
      debugPrint('CreateTournamentScreen - 종료 확인: 종료 콜백 호출');
      onExit!();
    } else {
      debugPrint('CreateTournamentScreen - 종료 확인: 종료 콜백이 없음');
    }
  }
}
