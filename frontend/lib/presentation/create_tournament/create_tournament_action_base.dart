import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/match_model.dart';


abstract class CreateTournamentAction {
  factory CreateTournamentAction.onDateChanged(DateTime date) => CreateTournamentAction.onDateChanged(date);
  factory CreateTournamentAction.onScoreChanged(String score, String type) => CreateTournamentAction.onScoreChanged(score, type);
  factory CreateTournamentAction.onTitleChanged(String title) => CreateTournamentAction.onTitleChanged(title);
  factory CreateTournamentAction.onGamesPerPlayerChanged(String gamesPerPlayer) => CreateTournamentAction.onGamesPerPlayerChanged(gamesPerPlayer);
  factory CreateTournamentAction.onIsDoublesChanged(bool isDoubles) => CreateTournamentAction.onIsDoublesChanged(isDoubles);
  factory CreateTournamentAction.onRecommendTitle() => CreateTournamentAction.onRecommendTitle();
  factory CreateTournamentAction.saveTournament() => CreateTournamentAction.saveTournament();
  factory CreateTournamentAction.updateProcess(int process) => CreateTournamentAction.updateProcess(process);
  
  // 플레이어 관련 액션
  factory CreateTournamentAction.addPlayer(String name) => CreateTournamentAction.addPlayer(name);
  factory CreateTournamentAction.updatePlayer(PlayerModel player) => CreateTournamentAction.updatePlayer(player);
  factory CreateTournamentAction.removePlayer(int playerId) => CreateTournamentAction.removePlayer(playerId);
  
  // 그룹 관련 액션
  factory CreateTournamentAction.fetchAllGroups() => CreateTournamentAction.fetchAllGroups();
  factory CreateTournamentAction.loadPlayersFromGroup(int groupId) => CreateTournamentAction.loadPlayersFromGroup(groupId);
  factory CreateTournamentAction.selectPlayerFromGroup(PlayerModel player) => CreateTournamentAction.selectPlayerFromGroup(player);

  // 매치 관련 액션
  factory CreateTournamentAction.addMatch(MatchModel match) => CreateTournamentAction.addMatch(match);
  factory CreateTournamentAction.updateMatch(MatchModel match) => CreateTournamentAction.updateMatch(match);
  factory CreateTournamentAction.removeMatch(int matchId) => CreateTournamentAction.removeMatch(matchId);
  factory CreateTournamentAction.generateMatches() => CreateTournamentAction.generateMatches();
  factory CreateTournamentAction.generateMatchesWithCourts(int courts) => CreateTournamentAction.generateMatchesWithCourts(courts);
  factory CreateTournamentAction.updateMatches(List<MatchModel> matches) => CreateTournamentAction.updateMatches(matches);

  // 대회 관련 액션
  factory CreateTournamentAction.onDiscard() => CreateTournamentAction.onDiscard();
  factory CreateTournamentAction.resetState() => CreateTournamentAction.resetState();
  factory CreateTournamentAction.updateExistingTournamentMatches() => CreateTournamentAction.updateExistingTournamentMatches();
  factory CreateTournamentAction.saveTournamentOrUpdateMatches() => CreateTournamentAction.saveTournamentOrUpdateMatches();
}