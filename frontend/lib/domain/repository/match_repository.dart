import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match_model.dart';

/// 매치 관련 리포지토리 인터페이스
abstract class MatchRepository {
  /// 토너먼트에 속한 모든 매치 조회
  Future<Result<List<MatchModel>>> fetchMatchesByTournament(int tournamentId);

  /// 새로운 매치 생성
  Future<Result<MatchModel>> createMatch({
    required int tournamentId,
    String? playerA,
    String? playerB,
    String? playerC,
    String? playerD,
  });

  /// 여러 매치 한번에 생성
  Future<Result<List<MatchModel>>> createMatches(
    List<Map<String, dynamic>> matchesData,
  );

  /// 매치 점수 업데이트
  Future<Result<MatchModel>> updateScore({
    required int matchId,
    required int? scoreA,
    required int? scoreB,
  });

  /// 매치 삭제
  Future<Result<Unit>> deleteMatch(int matchId);
}
