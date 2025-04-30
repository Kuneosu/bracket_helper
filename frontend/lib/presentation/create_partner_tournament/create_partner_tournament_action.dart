import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'create_partner_tournament_action.freezed.dart';

@freezed
sealed class CreatePartnerTournamentAction
    with _$CreatePartnerTournamentAction
    implements CreateTournamentActionBase {
  const factory CreatePartnerTournamentAction.onDateChanged(DateTime date) =
      OnDateChanged;
  const factory CreatePartnerTournamentAction.onScoreChanged(
    String score,
    String type,
  ) = OnScoreChanged;
  const factory CreatePartnerTournamentAction.onTitleChanged(String title) =
      OnTitleChanged;
  const factory CreatePartnerTournamentAction.onGamesPerPlayerChanged(
    String gamesPerPlayer,
  ) = OnGamesPerPlayerChanged;
  const factory CreatePartnerTournamentAction.onIsDoublesChanged(
    bool isDoubles,
  ) = OnIsDoublesChanged;
  const factory CreatePartnerTournamentAction.onRecommendTitle() =
      OnRecommendTitle;
  const factory CreatePartnerTournamentAction.saveTournament() = SaveTournament;
  const factory CreatePartnerTournamentAction.updateProcess(int process) =
      UpdateProcess;

  // 플레이어 관련 액션
  const factory CreatePartnerTournamentAction.addPlayer(String name) =
      AddPlayer;
  const factory CreatePartnerTournamentAction.updatePlayer(PlayerModel player) =
      UpdatePlayer;
  const factory CreatePartnerTournamentAction.removePlayer(int playerId) =
      RemovePlayer;

  // 그룹 관련 액션
  const factory CreatePartnerTournamentAction.fetchAllGroups() = FetchAllGroups;
  const factory CreatePartnerTournamentAction.loadPlayersFromGroup(
    int groupId,
  ) = LoadPlayersFromGroup;
  const factory CreatePartnerTournamentAction.selectPlayerFromGroup(
    PlayerModel player,
  ) = SelectPlayerFromGroup;

  // 매치 관련 액션
  const factory CreatePartnerTournamentAction.addMatch(MatchModel match) =
      AddMatch;
  const factory CreatePartnerTournamentAction.updateMatch(MatchModel match) =
      UpdateMatch;
  const factory CreatePartnerTournamentAction.removeMatch(int matchId) =
      RemoveMatch;
  const factory CreatePartnerTournamentAction.generateMatches() =
      GenerateMatches;
  const factory CreatePartnerTournamentAction.generateMatchesWithCourts(
    int courts,
  ) = GenerateMatchesWithCourts;
  const factory CreatePartnerTournamentAction.generateMatchesWithPartners(
    int courts,
    List<List<String>> fixedPairs,
  ) = GenerateMatchesWithPartners;
  const factory CreatePartnerTournamentAction.updateMatches(
    List<MatchModel> matches,
  ) = UpdateMatches;

  // 대회 관련 액션
  const factory CreatePartnerTournamentAction.onDiscard() = OnDiscard;
  const factory CreatePartnerTournamentAction.resetState() = ResetState;
  const factory CreatePartnerTournamentAction.updateExistingTournamentMatches() =
      UpdateExistingTournamentMatches;
  const factory CreatePartnerTournamentAction.saveTournamentOrUpdateMatches() =
      SaveTournamentOrUpdateMatches;
}
