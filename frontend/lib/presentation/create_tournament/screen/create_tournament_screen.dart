import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class CreateTournamentScreen extends StatelessWidget {
  final Widget body;
  final int currentPageIndex;
  const CreateTournamentScreen({
    super.key,
    required this.body,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(children: [Text('대진표 생성', style: TST.largeTextRegular)]),
        centerTitle: true,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProcessHeader(),
          Expanded(
            child: body,
          ),
        ],
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
}
