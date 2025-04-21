import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class MatchTypeToggleWidget extends StatelessWidget {
  final bool isDoubles;
  final Function(CreateTournamentAction) onAction;

  const MatchTypeToggleWidget({
    super.key,
    required this.isDoubles,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CST.primary100),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 46,
      child: Row(
        children: [
          // 복식 버튼
          Expanded(
            child: InkWell(
              onTap: () {
                onAction(
                  CreateTournamentAction.onIsDoublesChanged(true),
                );
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDoubles ? CST.primary100 : Colors.white,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(7),
                    right: Radius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 18,
                      color: isDoubles ? Colors.white : CST.primary100,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "복식",
                      style: TST.normalTextBold.copyWith(
                        color: isDoubles ? Colors.white : CST.primary100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 단식 버튼
          Expanded(
            child: InkWell(
              onTap: () {
                onAction(
                  CreateTournamentAction.onIsDoublesChanged(false),
                );
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isDoubles ? CST.primary100 : Colors.white,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.zero,
                    right: Radius.circular(7),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color: !isDoubles ? Colors.white : CST.primary100,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "단식",
                      style: TST.normalTextBold.copyWith(
                        color: !isDoubles ? Colors.white : CST.primary100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 