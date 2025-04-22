// ignore_for_file: annotate_overrides

import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';
@freezed
@JsonSerializable()
class TeamModel with _$TeamModel {
  final PlayerModel p1;
  final PlayerModel? p2; // 단식이면 null
  const TeamModel(this.p1, [this.p2]);
}
