import 'package:bracket_helper/core/utils/date_formatter.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class RecentTournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final void Function() onTapCard;
  final void Function() onTapDelete;
  const RecentTournamentCard({
    super.key,
    required this.tournament,
    required this.onTapCard,
    required this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: CST.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CST.black.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            padding: EdgeInsets.all(10),
            child: GestureDetector(
              onTap: onTapCard,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.title,
                    style: TST.mediumTextBold,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    DateFormatter.formatToYYYYMMDD(tournament.date),
                    style: TST.smallerTextRegular.copyWith(color: CST.gray2),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 100, color: CST.gray4),
          SizedBox(
            width: 39,
            height: 100,
            child: Center(
              child: GestureDetector(
                onTap: onTapDelete,
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: CST.error,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
