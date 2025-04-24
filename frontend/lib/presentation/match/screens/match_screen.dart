import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/match/match_action.dart';
import 'package:bracket_helper/presentation/match/match_view_model.dart';
import 'package:bracket_helper/presentation/match/widgets/bottom_action_buttons.dart';
import 'package:bracket_helper/presentation/match/widgets/bracket_tab_content.dart';
import 'package:bracket_helper/presentation/match/widgets/custom_tab_bar.dart';
import 'package:bracket_helper/presentation/match/widgets/header_section.dart';
import 'package:bracket_helper/presentation/match/widgets/rank_tab_content.dart';
import 'package:bracket_helper/presentation/match/widgets/tournament_info_dialog.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class MatchScreen extends StatelessWidget {
  final TournamentModel tournament;
  final List<MatchModel> matches;
  final List<PlayerModel> players;
  final bool isLoading;
  final String sortOption;
  final void Function(MatchAction) onAction;
  final Map<String, PlayerStats> playerStats;

  const MatchScreen({
    super.key,
    required this.tournament,
    required this.matches,
    required this.players,
    required this.onAction,
    required this.playerStats,
    this.sortOption = 'points',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.loading,
            style: TST.mediumTextBold.copyWith(color: CST.white),
          ),
          backgroundColor: CST.primary100,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: CST.primary100),
              const SizedBox(height: 16),
              Text(
                AppStrings.loadingBracket,
                style: TST.smallTextRegular.copyWith(color: CST.gray2),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            tournament.title,
            style: TST.mediumTextBold.copyWith(color: CST.white),
          ),
          backgroundColor: CST.primary100,
          centerTitle: true,
          automaticallyImplyLeading: true,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                TournamentInfoDialog.show(
                  context: context,
                  tournament: tournament,
                  playersCount: players.length,
                  matchesCount: matches.length,
                );
              },
              icon: Icon(Icons.info_outline, color: CST.white),
              tooltip: AppStrings.tournamentInfo,
            ),
          ],
        ),
        body: Column(
          children: [
            HeaderSection(
              playersCount: players.length,
              matchesCount: matches.length,
              onEditBracketPressed: () => onAction(const MatchAction.editBracket()),
              onShareBracketPressed: () => onAction(const MatchAction.captureAndShareBracket()),
            ),
            const CustomTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  // 대진표 탭
                  BracketTabContent(
                    matches: matches,
                    players: players,
                    onAction: onAction,
                  ),
                  
                  // 현재 순위 탭
                  RankTabContent(
                    players: players,
                    playerStats: playerStats,
                    sortOption: sortOption,
                    onSortOptionSelected: (option) => onAction(MatchAction.sortPlayersBy(option)),
                  ),
                ],
              ),
            ),
            BottomActionButtons(
              onShuffleBracketPressed: () => onAction(const MatchAction.shuffleBracket()),
              onFinishTournamentPressed: () => onAction(const MatchAction.finishTournament()),
            ),
          ],
        ),
      ),
    );
  }
}
