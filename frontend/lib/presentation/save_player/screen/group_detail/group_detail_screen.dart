import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/save_player/components/edit_player_dialog.dart';
import 'package:bracket_helper/presentation/save_player/components/empty_player_list_widget.dart';
import 'package:bracket_helper/presentation/save_player/components/group_header_widget.dart';
import 'package:bracket_helper/presentation/save_player/components/player_confirm_delete_dialog.dart';
import 'package:bracket_helper/presentation/save_player/components/player_list_item.dart';
import 'package:bracket_helper/presentation/save_player/components/player_search_field.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

class GroupDetailScreen extends StatelessWidget {
  final GroupModel group;
  final List<PlayerModel> players;
  final Function(SavePlayerAction) onAction;

  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.players,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // 그룹 색상 설정 (없으면 기본 파란색)
    final groupColor = group.color ?? CST.primary100;

    return RefreshIndicator(
      onRefresh: () async {
        onAction(SavePlayerAction.onRefresh());
        // 새로고침 효과를 위한 지연
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // 그룹 정보 영역
              GroupHeaderWidget(
                group: group,
                playerCount: players.length,
                groupColor: groupColor,
                onAddPlayer: () {
                  debugPrint('GroupDetailScreen: 선수 추가 버튼 클릭');
                  onAction(SavePlayerAction.onSavePlayer('', group.id));
                },
              ),

              const SizedBox(height: 24),

              // 선수 검색 필드
              PlayerSearchField(
                players: players,
                groupColor: groupColor,
                onEditPlayer:
                    (player) => _showEditPlayerDialog(context, player),
                onDeletePlayer:
                    (player) => _showDeleteConfirmDialog(context, player),
              ),

              const SizedBox(height: 16),

              // 선수 목록 헤더
              Row(
                children: [
                  Text('선수 목록', style: TST.mediumTextBold),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 8),

              // 선수 목록 또는 빈 상태 메시지
              players.isEmpty
                  ? EmptyPlayerListWidget(
                    onAddPlayer: () {
                      debugPrint('GroupDetailScreen: 빈 화면에서 선수 추가 버튼 클릭');
                      onAction(SavePlayerAction.onSavePlayer('', group.id));
                    },
                  )
                  : _buildPlayerList(context),

              // 하단 여백 추가
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 선수 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(BuildContext context, PlayerModel player) {
    PlayerConfirmDeleteDialog.show(
      context: context,
      player: player,
      onDelete: (playerId) {
        onAction(SavePlayerAction.onDeletePlayer(playerId, group.id));
      },
    );
  }

  // 선수 정보 수정 다이얼로그
  void _showEditPlayerDialog(BuildContext context, PlayerModel player) {
    EditPlayerDialog.show(
      context: context,
      player: player,
      onUpdate: (playerId, newName) {
        onAction(
          SavePlayerAction.onUpdatePlayer(playerId: playerId, newName: newName),
        );
      },
    );
  }

  // 선수 목록 표시 위젯
  Widget _buildPlayerList(BuildContext context) {
    return Column(
      children: List.generate(players.length, (index) {
        final player = players[index];
        return PlayerListItem(
          player: player,
          index: index + 1,
          isFirst: index == 0,
          isLast: index == players.length - 1,
          onTap: () {
            // 선수 상세 정보 보기
          },
          onEdit: () {
            // 선수 정보 수정 다이얼로그 표시
            _showEditPlayerDialog(context, player);
          },
          onDelete: () {
            // 선수 삭제 확인 다이얼로그 표시
            _showDeleteConfirmDialog(context, player);
          },
        );
      }),
    );
  }
}
