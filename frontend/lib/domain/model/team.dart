import 'package:bracket_helper/domain/model/player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';

@freezed
@JsonSerializable()
class Team with _$Team {
  final Player p1;
  final Player? p2; // 단식이면 null
  const Team(this.p1, [this.p2]);
}
