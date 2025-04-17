import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/core/presentation/components/default_date_picker.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchInfoScreen extends StatelessWidget {
  const MatchInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("대회명", style: TST.largeTextBold),
          SizedBox(height: 10),
          DefaultTextField(hintText: '대회명을 입력해주세요'),
          SizedBox(height: 10),
          Row(children: [_buildRecommendTitle()]),
          SizedBox(height: 20),
          Text("대회 날짜", style: TST.largeTextBold),
          SizedBox(height: 10),
          DefaultDatePicker(),
          SizedBox(height: 20),
          Text("승점 입력", style: TST.largeTextBold),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Text("승", style: TST.largeTextRegular),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    child: DefaultTextField(
                      hintText: '1',
                      textAlign: TextAlign.center,
                      initialValue: '1',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("무", style: TST.largeTextRegular),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    child: DefaultTextField(
                      hintText: '0',
                      textAlign: TextAlign.center,
                      initialValue: '0',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("패", style: TST.largeTextRegular),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    child: DefaultTextField(
                      hintText: '0',
                      textAlign: TextAlign.center,
                      initialValue: '0',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text("1인당 게임수", style: TST.largeTextBold),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildMatchPerPlayer(), _buildMatchTypeToggle()],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Spacer(),
              DefaultButton(
                text: '다음',
                onTap: () {
                  context.pushReplacement(
                    '${RoutePaths.createMatch}${RoutePaths.addPlayer}',
                  );
                },
                width: 70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchTypeToggle() {
    // UI만 구현하고 상태 변경 없이 복식이 선택된 상태로 표시
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CST.primary100),
        borderRadius: BorderRadius.circular(4),
      ),
      height: 46,
      child: Row(
        children: [
          // 복식 버튼 (선택된 상태)
          Container(
            width: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CST.primary100, // 복식이 선택된 상태
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(3),
                right: Radius.zero,
              ),
            ),
            child: Text(
              "복식",
              style: TST.largeTextRegular.copyWith(color: Colors.white),
            ),
          ),
          // 단식 버튼 (선택되지 않은 상태)
          Container(
            width: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.horizontal(
                left: Radius.zero,
                right: Radius.circular(3),
              ),
            ),
            child: Text(
              "단식",
              style: TST.largeTextRegular.copyWith(color: CST.primary100),
            ),
          ),
        ],
      ),
    );
  }

  Row _buildMatchPerPlayer() {
    final border = BorderSide(color: CST.primary100, width: 1);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border(top: border, bottom: border, left: border),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Text(
            "-",
            style: TST.largeTextRegular.copyWith(color: CST.primary100),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: CST.primary100, width: 1),
          ),
          child: Text(
            "4",
            style: TST.largeTextBold.copyWith(color: CST.primary100),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border(right: border, top: border, bottom: border),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            "+",
            style: TST.largeTextRegular.copyWith(color: CST.primary100),
          ),
        ),
      ],
    );
  }

  Container _buildRecommendTitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CST.gray4,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('2025-04-14(월)', style: TST.smallTextRegular),
    );
  }
}
