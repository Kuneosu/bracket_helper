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
}