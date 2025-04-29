import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class PrintMatchItem extends StatelessWidget {
  final MatchModel match;
  final int index;

  const PrintMatchItem({
    super.key,
    required this.match,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CST.gray4, width: 1),
      ),
      child: Row(
        children: [
          // 매치 번호
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CST.primary20,
              shape: BoxShape.circle,
            ),
            child: Text(
              "${index + 1}",
              style: TST.smallTextBold.copyWith(color: CST.primary100),
            ),
          ),
          const SizedBox(width: 10),
          // 왼쪽 팀
          Expanded(
            flex: 3,
            child: match.isDoubles
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        match.playerA!,
                        style: TST.normalTextBold.copyWith(color: CST.gray1),
                        textAlign: TextAlign.right,
                      ),
                      Container(
                        width: 40,
                        height: 1,
                        color: CST.gray4,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      Text(
                        match.playerC!,
                        style: TST.normalTextBold.copyWith(color: CST.gray1),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      match.playerA!,
                      style: TST.normalTextBold.copyWith(color: CST.gray1),
                      textAlign: TextAlign.right,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // 왼쪽 점수 - 입력 필드 대신 정적 텍스트로 표시
          Text("vs", style: TST.smallTextBold.copyWith(color: CST.primary100)),
          const SizedBox(width: 12),
          // 오른쪽 팀
          Expanded(
            flex: 3,
            child: match.isDoubles
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        match.playerB!,
                        style: TST.normalTextBold.copyWith(color: CST.gray1),
                      ),
                      Container(
                        width: 40,
                        height: 1,
                        color: CST.gray4,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      Text(
                        match.playerD!,
                        style: TST.normalTextBold.copyWith(color: CST.gray1),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      match.playerB!,
                      style: TST.normalTextBold.copyWith(color: CST.gray1),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
} 