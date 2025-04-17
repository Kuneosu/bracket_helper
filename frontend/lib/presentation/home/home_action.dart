import 'package:freezed_annotation/freezed_annotation.dart';
part 'home_action.freezed.dart';

@freezed
sealed class HomeAction with _$HomeAction {
  const factory HomeAction.onRefresh() = OnRefresh;
  const factory HomeAction.onTapHelp() = OnTapHelp;
  const factory HomeAction.onTapAllTournament() = OnTapAllTournament;
  const factory HomeAction.onTapCreateTournament() = OnTapCreateTournament;
  const factory HomeAction.onTapPlayerManagement() = OnTapPlayerManagement;
  const factory HomeAction.onTapGroupManagement() = OnTapGroupManagement;
  const factory HomeAction.onTapStatistics() = OnTapStatistics;
  const factory HomeAction.onTapMatchCard() = OnTapMatchCard;
  const factory HomeAction.onTapDeleteTournament() = OnTapDeleteTournament;
}
