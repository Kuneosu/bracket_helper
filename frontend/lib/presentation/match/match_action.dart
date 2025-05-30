import 'package:freezed_annotation/freezed_annotation.dart';
part 'match_action.freezed.dart';

@freezed
sealed class MatchAction with _$MatchAction {
  const factory MatchAction.updateScore({
    required int matchId,
    int? scoreA,
    int? scoreB,
  }) = UpdateScore;
  
  const factory MatchAction.captureAndShareBracket() = CaptureAndShareBracket;
  const factory MatchAction.shuffleBracket() = ShuffleBracket;
  const factory MatchAction.finishTournament() = FinishTournament;
  const factory MatchAction.editBracket() = EditBracket;
  const factory MatchAction.editPartnerBracket() = EditPartnerBracket;

  const factory MatchAction.sortPlayersBy(String sortOption) = SortPlayersBy;
}
