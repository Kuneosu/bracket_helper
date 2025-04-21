import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class PlayerListHeader extends StatelessWidget {
  final int playerCount;
  final VoidCallback onAddPlayerTap;

  const PlayerListHeader({
    super.key,
    required this.playerCount,
    required this.onAddPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CST.gray3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("참가 인원 수 : $playerCount 명", style: TST.largeTextRegular),
          DefaultButton(
            text: "선수 추가하기",
            onTap: onAddPlayerTap,
            width: 133,
            textStyle: TST.normalTextBold,
          ),
        ],
      ),
    );
  }
} 