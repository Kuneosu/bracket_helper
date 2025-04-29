import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_model.freezed.dart';

@freezed
@JsonSerializable()
class MatchModel with _$MatchModel {
  final int id;
  final int? tournamentId;
  final String? playerA;
  final String? playerB;
  final String? playerC;
  final String? playerD;
  final int? scoreA;
  final int? scoreB;
  final int? ord;

  MatchModel({
    required this.id,
    this.tournamentId,
    this.playerA,
    this.playerB,
    this.playerC,
    this.playerD,
    this.scoreA,
    this.scoreB,
    this.ord,
  });

  /// 경기 결과가 있는지 확인
  bool get hasResult => scoreA != null && scoreB != null;

  /// 무승부인지 확인
  bool get isDraw => hasResult && scoreA == scoreB;

  /// A팀이 승리했는지 확인
  bool get isTeamAWinner => hasResult && scoreA! > scoreB!;

  /// B팀이 승리했는지 확인
  bool get isTeamBWinner => hasResult && scoreB! > scoreA!;

  /// 복식 경기인지 확인
  bool get isDoubles => playerC != null && playerD != null;
}
