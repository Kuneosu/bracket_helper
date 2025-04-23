import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_tournament_state.freezed.dart';

@freezed
@JsonSerializable()
class CreateTournamentState with _$CreateTournamentState {
  final bool isLoading;
  final String? errorMessage;
  final List<GroupModel> groups;
  final List<PlayerModel> players;
  final TournamentModel tournament;
  final List<MatchModel> matches;
  final bool isEditMode;

  CreateTournamentState({
    this.isLoading = false,
    this.errorMessage,
    this.groups = const [],
    this.players = const [],
    required this.tournament,
    this.matches = const [],
    this.isEditMode = false,
  });
}
