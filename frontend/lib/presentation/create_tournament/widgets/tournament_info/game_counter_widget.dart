import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class GameCounterWidget extends StatelessWidget {
  final int gamesPerPlayer;
  final Function(CreateTournamentAction) onAction;

  const GameCounterWidget({
    super.key,
    required this.gamesPerPlayer,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCounterButton(
            icon: Icons.remove,
            onTap: () {
              if (gamesPerPlayer > 1) {
                onAction(
                  CreateTournamentAction.onGamesPerPlayerChanged(
                    (gamesPerPlayer - 1).toString(),
                  ),
                );
              }
            },
            isLeft: true,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: CST.primary100, width: 1),
            ),
            child: Text(
              "$gamesPerPlayer",
              style: TST.largeTextBold.copyWith(color: CST.primary100),
            ),
          ),
          _buildCounterButton(
            icon: Icons.add,
            onTap: () {
              onAction(
                CreateTournamentAction.onGamesPerPlayerChanged(
                  (gamesPerPlayer + 1).toString(),
                ),
              );
            },
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: CST.primary100,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? Radius.circular(8) : Radius.zero,
            right: !isLeft ? Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
} 