import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/match/match_view_model.dart';
import 'package:bracket_helper/presentation/match/widgets/player_rank_item.dart';
import 'package:bracket_helper/presentation/match/widgets/rank_header.dart';
import 'package:bracket_helper/presentation/match/widgets/sort_option_bar.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

class RankTabContent extends StatelessWidget {
  final List<PlayerModel> players;
  final Map<String, PlayerStats> playerStats;
  final String sortOption;
  final Function(String) onSortOptionSelected;

  const RankTabContent({
    super.key,
    required this.players,
    required this.playerStats,
    required this.sortOption,
    required this.onSortOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 정렬 옵션 선택 UI
        SortOptionBar(
          selectedOption: sortOption,
          onSortOptionSelected: onSortOptionSelected,
        ),
        
        // 랭킹 테이블 섹션
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CST.gray4),
            ),
            child: Column(
              children: [
                // 테이블 헤더
                const RankHeader(),
                
                // 선수 목록
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      final stats = playerStats[player.name];

                      return PlayerRankItem(
                        player: player,
                        rank: index + 1,
                        isEven: index % 2 == 0,
                        isLast: index == players.length - 1,
                        stats: stats,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
} 