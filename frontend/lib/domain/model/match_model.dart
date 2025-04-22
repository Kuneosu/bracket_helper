import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_model.freezed.dart';

@freezed
@JsonSerializable()
class MatchModel with _$MatchModel {
  final int id;
  final int? tournamentId;
  final int? teamAId;
  final int? teamBId;
  final String? teamAName;
  final String? teamBName;
  final int? scoreA;
  final int? scoreB;
  final int? order;

  MatchModel({
    required this.id,
    this.tournamentId,
    this.teamAId,
    this.teamBId,
    this.teamAName,
    this.teamBName,
    this.scoreA,
    this.scoreB,
    this.order,
  });

  /// 승자 팀 ID 반환, 무승부이거나 결과가 없으면 null 반환
  int? get winnerTeamId {
    if (scoreA == null || scoreB == null) return null;
    if (scoreA == scoreB) return null;
    return scoreA! > scoreB! ? teamAId : teamBId;
  }

  /// 패자 팀 ID 반환, 무승부이거나 결과가 없으면 null 반환
  int? get loserTeamId {
    if (scoreA == null || scoreB == null) return null;
    if (scoreA == scoreB) return null;
    return scoreA! > scoreB! ? teamBId : teamAId;
  }

  /// 경기 결과가 있는지 확인
  bool get hasResult => scoreA != null && scoreB != null;

  /// 무승부인지 확인
  bool get isDraw => hasResult && scoreA == scoreB;

  /// A팀이 승리했는지 확인
  bool get isTeamAWinner => hasResult && scoreA! > scoreB!;

  /// B팀이 승리했는지 확인
  bool get isTeamBWinner => hasResult && scoreB! > scoreA!;
}
