import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

/// 선수 선택 목록 위젯
class PlayerSelectionList extends StatelessWidget {
  final List<PlayerModel> players;
  final List<PlayerModel> tournamentPlayers;
  final Map<int, bool> selectedPlayers;
  final Function(PlayerModel) onToggleSelection;
  final int? selectedGroupId;

  const PlayerSelectionList({
    super.key,
    required this.players,
    required this.tournamentPlayers,
    required this.selectedPlayers,
    required this.onToggleSelection,
    this.selectedGroupId,
  });

  @override
  Widget build(BuildContext context) {
    // 그룹 선택 안 했으면 안내 메시지
    if (selectedGroupId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 40, color: CST.primary60),
            const SizedBox(height: 16),
            Text('위에서 그룹을 선택하세요', style: TextStyle(color: CST.gray2)),
          ],
        ),
      );
    }

    // 선수가 없으면 안내 메시지
    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off, size: 40, color: CST.gray3),
            const SizedBox(height: 16),
            Text('이 그룹에는 선수가 없습니다.', style: TextStyle(color: CST.gray2)),
          ],
        ),
      );
    }

    // 선수 목록 표시
    return ListView.separated(
      padding: EdgeInsets.all(8),
      itemCount: players.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: CST.gray4.withValues(alpha: 0.5),
          ),
      itemBuilder: (context, index) {
        final player = players[index];
        final isSelected = selectedPlayers.containsKey(player.id);

        // 오직 이름으로만 비교
        final isAlreadyAdded = tournamentPlayers.any((p) => p.name == player.name);

        // 디버깅용 로그
        if (index < 5) {
          debugPrint(
            'PlayerSelectionList - 선수[$index]: ${player.name}, ID: ${player.id}, 이미 추가됨: $isAlreadyAdded',
          );
          if (isAlreadyAdded) {
            final matchedPlayer = tournamentPlayers.firstWhere(
              (p) => p.name == player.name,
              orElse: () => PlayerModel(id: -1, name: ''),
            );
            if (matchedPlayer.id != -1) {
              debugPrint('  이름이 일치하는 선수: ${matchedPlayer.name}, ID: ${matchedPlayer.id}');
            }
          }
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            player.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isAlreadyAdded ? CST.gray3 : CST.gray1,
            ),
          ),
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? CST.primary100 : Colors.transparent,
              border: Border.all(
                color:
                    isAlreadyAdded
                    ? CST.gray3
                    : isSelected
                        ? CST.primary100
                        : CST.gray2,
                width: 2,
              ),
            ),
            child:
                isSelected
                ? Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          enabled: !isAlreadyAdded,
          subtitle:
              isAlreadyAdded
              ? Row(
                  children: [
                    Icon(Icons.info_outline, size: 12, color: CST.gray3),
                    const SizedBox(width: 4),
                    Text(
                      '이미 추가됨',
                      style: TextStyle(color: CST.gray3, fontSize: 12),
                    ),
                  ],
                )
              : null,
          tileColor: isSelected ? CST.primary20 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onTap: isAlreadyAdded ? null : () => onToggleSelection(player),
        );
      },
    );
  }
}
