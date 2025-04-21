import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
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
    
    final List<MatchModel> displayMatches = matches.isEmpty 
        ? [
            MatchModel(id: 1, teamAId: 1, teamBId: 2, scoreA: 1, scoreB: 2),
            MatchModel(id: 2, teamAId: 3, teamBId: 4, scoreA: 3, scoreB: 4),
            MatchModel(id: 3, teamAId: 1, teamBId: 3, scoreA: 1, scoreB: 3),
          ] 
        : matches;
        
    final List<PlayerModel> displayPlayers = players.isEmpty 
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
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: displayMatches.length + 1,
              itemBuilder: (context, index) {
                if (index == displayMatches.length) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: CST.primary40,
                      border: Border(bottom: BorderSide(color: CST.gray3)),
                    ),
                    child: Center(
                      child: Text(
                        "+",
                        style: TST.mediumTextBold.copyWith(
                          color: CST.primary100,
                        ),
                      ),
                    ),
                  );
                } else {
                  return _buildMatchList(index, displayPlayers);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 40,
              top: 20,
            ),
            child: Row(
              children: [
                DefaultButton(
                  text: "이전",
                  onTap: () {
                    context.pop();
                  },
                  width: 70,
                ),
                Spacer(),
                DefaultButton(
                  text: "다음",
                  onTap: () {
                    // 프로세스 진행 상태 업데이트
                    onAction(CreateTournamentAction.updateProcess(3));
                    
                    context.go(RoutePaths.match);
                  },
                  width: 70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 상단 헤더 위젯
  Widget _buildHeader(int playerCount, int matchCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CST.gray3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("참가 인원 수 : $playerCount 명", style: TST.largeTextRegular),
              Text("경기 수 : $matchCount 경기", style: TST.largeTextRegular),
            ],
          ),
          DefaultButton(
            text: "초기화",
            onTap: () {},
            width: 85,
            textStyle: TST.normalTextBold,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(int index, List<PlayerModel> playerList) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CST.gray3)),
      ),
      child: Row(
        children: [
          Text("${index + 1}", style: TST.largeTextRegular),
          Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: CST.gray3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(playerList[0].name, style: TST.mediumTextRegular),
              ),
              SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: CST.gray3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(playerList[1].name, style: TST.mediumTextRegular),
              ),
            ],
          ),
          Spacer(),
          Text("vs", style: TST.smallTextBold),
          Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: CST.gray3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(playerList[2].name, style: TST.mediumTextRegular),
              ),
              SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: CST.gray3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(playerList[3].name, style: TST.mediumTextRegular),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
