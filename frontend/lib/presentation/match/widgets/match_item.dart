import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/presentation/match/match_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class MatchItem extends StatelessWidget {
  final MatchModel match;
  final int index;
  final void Function(MatchAction) onAction;

  const MatchItem({
    super.key,
    required this.match,
    required this.index,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
          const SizedBox(width: 24),
          // 왼쪽 점수
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CST.primary60, width: 1),
            ),
            child: DefaultTextField(
              textAlign: TextAlign.center, 
              hintText: '0',
              isNumberField: true,
              onChanged: (value) {
                final score = int.tryParse(value);
                onAction(MatchAction.updateScore(
                  matchId: match.id,
                  scoreA: score,
                  scoreB: match.scoreB,
                ));
              },
              initialValue: match.scoreA?.toString() ?? '0',
            ),
          ),
          // VS 표시
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Text(
              ":",
              style: TST.smallTextBold.copyWith(color: CST.primary100),
            ),
          ),
          // 오른쪽 점수
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CST.primary60, width: 1),
            ),
            child: DefaultTextField(
              textAlign: TextAlign.center, 
              hintText: '0',
              isNumberField: true,
              onChanged: (value) {
                final score = int.tryParse(value);
                onAction(MatchAction.updateScore(
                  matchId: match.id,
                  scoreA: match.scoreA,
                  scoreB: score,
                ));
              },
              initialValue: match.scoreB?.toString() ?? '0',
            ),
          ),
          const SizedBox(width: 24),
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