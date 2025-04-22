import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/index.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditMatchScreen extends StatelessWidget {
  final TournamentModel tournament;
  final List<PlayerModel> players;
  final List<MatchModel> matches;
  final Function(CreateTournamentAction) onAction;

  const EditMatchScreen({
    super.key,
    required this.tournament,
    required this.players,
    required this.matches,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final playerCount = players.isEmpty ? 4 : players.length;
    final matchCount = matches.isEmpty ? 3 : matches.length;

    final List<MatchModel> displayMatches =
        matches.isEmpty
            ? [
              MatchModel(id: 1, teamAId: 1, teamBId: 2, scoreA: 1, scoreB: 2),
              MatchModel(id: 2, teamAId: 3, teamBId: 4, scoreA: 3, scoreB: 4),
              MatchModel(id: 3, teamAId: 1, teamBId: 3, scoreA: 1, scoreB: 3),
            ]
            : matches;

    final List<PlayerModel> displayPlayers =
        players.isEmpty
            ? [
              PlayerModel(id: 1, name: "홍길동"),
              PlayerModel(id: 2, name: "이순신"),
              PlayerModel(id: 3, name: "김유신"),
              PlayerModel(id: 4, name: "오쌤"),
            ]
            : players;

    return Expanded(
      child: Column(
        children: [
          _buildHeader(playerCount, matchCount),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: displayMatches.length + 1,
                itemBuilder: (context, index) {
                  if (index == displayMatches.length) {
                    return _buildAddMatchButton();
                  } else {
                    return _buildMatchItem(
                      index,
                      displayPlayers,
                      displayMatches[index],
                    );
                  }
                },
              ),
            ),
          ),
          NavigationButtonsWidget(
            onPrevious: () {
              context.go(
                '${RoutePaths.createTournament}${RoutePaths.addPlayer}',
              );
            },
            onNext: () {
              onAction(CreateTournamentAction.updateProcess(3));
              context.go(RoutePaths.match);
            },
          ),
        ],
      ),
    );
  }

  // 상단 헤더 위젯
  Widget _buildHeader(int playerCount, int matchCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CST.gray3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, color: CST.primary100, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "참가 인원 수: $playerCount명",
                    style: TST.normalTextRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.sports_handball_outlined,
                    color: CST.primary100,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "경기 수: $matchCount경기",
                    style: TST.normalTextRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          DefaultButton(
            text: "초기화",
            onTap: () {},
            width: 70,
            height: 36,
            textStyle: TST.smallTextBold.copyWith(color: Colors.white),
            color: CST.primary100,
          ),
        ],
      ),
    );
  }

  // 추가 버튼 위젯
  Widget _buildAddMatchButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: CST.primary40.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CST.primary60.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: CST.primary100, size: 18),
                const SizedBox(width: 8),
                Text(
                  "새 경기 추가",
                  style: TST.smallTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 매치 아이템 위젯
  Widget _buildMatchItem(
    int index,
    List<PlayerModel> playerList,
    MatchModel match,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CST.gray3.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: CST.primary100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: TST.smallTextBold.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTeam([playerList[0].name, playerList[1].name]),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CST.primary40.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CST.primary60.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      "VS",
                      style: TST.smallTextBold.copyWith(color: CST.primary100),
                    ),
                  ),
                  _buildTeam([playerList[2].name, playerList[3].name]),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: CST.primary100, size: 18),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  // 팀 위젯
  Widget _buildTeam(List<String> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...players.map((player) => _buildPlayerName(player))],
    );
  }

  // 플레이어 이름 위젯
  Widget _buildPlayerName(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CST.primary40.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: CST.primary60.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(name, style: TST.smallTextBold),
    );
  }
}
