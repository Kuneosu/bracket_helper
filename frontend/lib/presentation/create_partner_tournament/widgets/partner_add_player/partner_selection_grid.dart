import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/widgets/partner_add_player/partner_grid_item.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

/// 파트너를 선택할 수 있는 그리드 위젯
class PartnerSelectionGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final List<List<String>> fixedPairs;
  final int? firstSelectedPlayerId;
  final Function(PlayerModel) onSelectPlayer;

  const PartnerSelectionGrid({
    super.key,
    required this.players,
    required this.fixedPairs,
    required this.firstSelectedPlayerId,
    required this.onSelectPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.person_search, size: 16, color: CST.primary100),
                SizedBox(width: 8),
                Text(
                  '선수 선택',
                  style: TST.mediumTextBold.copyWith(color: CST.primary100),
                ),
                Spacer(),
                if (firstSelectedPlayerId != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CST.primary20,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CST.primary60),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add, color: CST.primary100, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '파트너 선택 중',
                          style: TST.smallTextBold.copyWith(
                            color: CST.primary100,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                
                // 이미 파트너가 있는지 확인
                bool hasPartner = false;
                for (var pair in fixedPairs) {
                  if (pair.contains(player.name)) {
                    hasPartner = true;
                    break;
                  }
                }
                
                return PartnerGridItem(
                  player: player,
                  isSelected: firstSelectedPlayerId == player.id,
                  hasPartner: hasPartner,
                  index: index + 1,
                  onTap: onSelectPlayer,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 