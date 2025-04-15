import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match.dart';

/// 매치 관련 리포지토리 인터페이스
abstract class MatchRepository {
  /// 토너먼트에 속한 모든 매치 조회
  Future<Result<List<Match>>> fetchMatchesByTournament(int tournamentId);

  /// 새로운 매치 생성
  Future<Result<Match>> createMatch({
    required int tournamentId,
    int? teamAId,
    int? teamBId,
    String? teamAName,
    String? teamBName,
  });

  /// 여러 매치 한번에 생성
  Future<Result<List<Match>>> createMatches(
    List<Map<String, dynamic>> matchesData,
  );

  /// 매치 점수 업데이트
  Future<Result<Match>> updateScore({
    required int matchId,
    required int? scoreA,
    required int? scoreB,
  });

  /// 매치 삭제
  Future<Result<Unit>> deleteMatch(int matchId);
}
