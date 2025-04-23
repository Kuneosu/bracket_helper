import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_state.freezed.dart';

@freezed
@JsonSerializable()
class MatchState with _$MatchState {
  final bool isLoading;
  final String? errorMessage;
  final TournamentModel tournament;
  final List<MatchModel> matches;
  final List<PlayerModel> players;
  final String sortOption;

  MatchState({
    this.isLoading = false,
    this.errorMessage,
    required this.tournament,
    this.matches = const [],
    this.players = const [],
    this.sortOption = 'points',
  });
}
