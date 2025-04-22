import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'create_tournament_action.freezed.dart';

@freezed
sealed class CreateTournamentAction with _$CreateTournamentAction {
  const factory CreateTournamentAction.onDateChanged(DateTime date) = OnDateChanged;
  const factory CreateTournamentAction.onScoreChanged(String score, String type) = OnScoreChanged;
  const factory CreateTournamentAction.onTitleChanged(String title) = OnTitleChanged;
  const factory CreateTournamentAction.onGamesPerPlayerChanged(String gamesPerPlayer) = OnGamesPerPlayerChanged;
  const factory CreateTournamentAction.onIsDoublesChanged(bool isDoubles) = OnIsDoublesChanged;
  const factory CreateTournamentAction.onRecommendTitle() = OnRecommendTitle;
  const factory CreateTournamentAction.saveTournament() = SaveTournament;
  const factory CreateTournamentAction.updateProcess(int process) = UpdateProcess;
  
  // 플레이어 관련 액션
  const factory CreateTournamentAction.addPlayer(String name) = AddPlayer;
  const factory CreateTournamentAction.updatePlayer(PlayerModel player) = UpdatePlayer;
  const factory CreateTournamentAction.removePlayer(int playerId) = RemovePlayer;
  
  // 그룹 관련 액션
  const factory CreateTournamentAction.fetchAllGroups() = FetchAllGroups;
  const factory CreateTournamentAction.loadPlayersFromGroup(int groupId) = LoadPlayersFromGroup;
  const factory CreateTournamentAction.selectPlayerFromGroup(PlayerModel player) = SelectPlayerFromGroup;

  // 매치 관련 액션
  const factory CreateTournamentAction.addMatch(MatchModel match) = AddMatch;
  const factory CreateTournamentAction.updateMatch(MatchModel match) = UpdateMatch;
  const factory CreateTournamentAction.removeMatch(int matchId) = RemoveMatch;
  const factory CreateTournamentAction.generateMatches() = GenerateMatches;
  const factory CreateTournamentAction.generateMatchesWithCourts(int courts) = GenerateMatchesWithCourts;
  const factory CreateTournamentAction.updateMatches(List<MatchModel> matches) = UpdateMatches;

  // 대회 관련 액션
  const factory CreateTournamentAction.onDiscard() = OnDiscard;
}