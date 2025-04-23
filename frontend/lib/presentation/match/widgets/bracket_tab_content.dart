import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/match/match_action.dart';
import 'package:bracket_helper/presentation/match/widgets/match_item.dart';
import 'package:flutter/material.dart';

class BracketTabContent extends StatelessWidget {
  final List<MatchModel> matches;
  final List<PlayerModel> players;
  final void Function(MatchAction) onAction;

  const BracketTabContent({
    super.key,
    required this.matches,
    required this.players,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return MatchItem(
          match: matches[index],
          index: index,
          onAction: onAction,
        );
      },
    );
  }
} 