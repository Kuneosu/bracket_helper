// ignore_for_file: annotate_overrides

import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';

@freezed
@JsonSerializable()
class Team with _$Team {
  final PlayerModel p1;
  final PlayerModel? p2; // 단식이면 null
  const Team(this.p1, [this.p2]);
}
