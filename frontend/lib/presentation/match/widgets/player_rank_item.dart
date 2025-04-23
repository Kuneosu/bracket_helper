import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class PlayerRankItem extends StatelessWidget {
  final PlayerModel player;
  final int rank;
  final bool isEven;
  final bool isLast;

  const PlayerRankItem({
    super.key,
    required this.player,
    required this.rank,
    this.isEven = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : CST.primary20,
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: CST.gray4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildRankItem('${rank}', 0),
          ),
          Expanded(
            flex: 2,
            child: _buildRankItem(player.name, 0),
          ),
          Expanded(flex: 1, child: _buildRankItem('1', 0)),
          Expanded(flex: 1, child: _buildRankItem('1', 0)),
          Expanded(flex: 1, child: _buildRankItem('1', 0)),
          Expanded(flex: 1, child: _buildRankItem('1', 0)),
          Expanded(flex: 1, child: _buildRankItem('3', 0)),
        ],
      ),
    );
  }

  Widget _buildRankItem(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TST.smallTextRegular,
        textAlign: TextAlign.center,
      ),
    );
  }
} 