// ignore_for_file: annotate_overrides

import 'package:bracket_helper/domain/model/team.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';

@freezed
@JsonSerializable()
class Match with _$Match {
  final int id; // 매치 고유 아이디
  final int tournamentId; // 토너먼트 고유 아이디
  final int order; // 매치 순서
  final Team teamA; // 팀 A
  final Team teamB; // 팀 B
  int? scoreA; // 팀 A 점수
  int? scoreB; // 팀 B 점수

  Match({
    required this.id,
    required this.tournamentId,
    required this.order,
    required this.teamA,
    required this.teamB,
    this.scoreA,
    this.scoreB,
  });
}
