import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/add_player/inline_editable_player_item.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

class DismissiblePlayerItem extends StatelessWidget {
  final PlayerModel player;
  final int index;
  final Function(CreateTournamentAction) onAction;

  const DismissiblePlayerItem({
    super.key,
    required this.player,
    required this.index,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('player_${player.id}'),
      background: Container(
        color: CST.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onAction(CreateTournamentAction.removePlayer(player.id));
      },
      child: Builder(
        // Builder 위젯을 사용하여 현재 BuildContext를 얻음
        builder: (BuildContext context) {
          return InlineEditablePlayerItem(
            player: player,
            index: index,
            onAction: onAction,
          );
        },
      ),
    );
  }
} 