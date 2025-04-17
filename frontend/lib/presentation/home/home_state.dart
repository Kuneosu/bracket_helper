import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';
part 'home_state.g.dart';

@freezed
@JsonSerializable()
class HomeState with _$HomeState {
  final List<TournamentModel> tournaments;
  final String? errorMessage;
  final bool isLoading;

  HomeState({
    this.tournaments = const [],
    this.errorMessage,
    this.isLoading = false,
  });

  factory HomeState.fromJson(Map<String, Object?> json) =>
      _$HomeStateFromJson(json);

  Map<String, dynamic> toJson() => _$HomeStateToJson(this);
}
