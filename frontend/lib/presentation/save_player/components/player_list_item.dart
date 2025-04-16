import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class PlayerListItem extends StatelessWidget {
  final Player player;
  final int index;
  final bool isFirst;
  final bool isLast;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.index,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: CST.gray4, width: 1);
    final firstBorder = Border(top: border, left: border, right: border);
    final lastBorder = Border(bottom: border, left: border, right: border);
    final middleBorder = Border.all(color: CST.gray4, width: 1);
    final firstBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    );
    final lastBorderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(10),
    );
    final middleBorderRadius = BorderRadius.all(Radius.circular(0));

    final nowBorder =
        isFirst
            ? firstBorder
            : isLast
            ? lastBorder
            : middleBorder;
    final nowBorderRadius =
        isFirst
            ? firstBorderRadius
            : isLast
            ? lastBorderRadius
            : middleBorderRadius;

    return Container(
      width: double.infinity,
      height: 66,
      decoration: BoxDecoration(
        color: CST.white,
        borderRadius: nowBorderRadius,
        border: nowBorder,
      ),
      child: Row(
        children: [
          SizedBox(width: 20),
          Text(index.toString(), style: TST.mediumTextBold),
          Spacer(),
          Text(player.name, style: TST.mediumTextBold),
          Spacer(),
        ],
      ),
    );
  }
}
