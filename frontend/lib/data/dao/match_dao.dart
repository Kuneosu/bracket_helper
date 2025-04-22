import 'package:drift/drift.dart';
import '../database/tables.dart';
import '../database/app_database.dart';
import 'package:bracket_helper/domain/model/match_model.dart' as domain;
import 'package:flutter/foundation.dart';

part 'match_dao.g.dart';

@DriftAccessor(tables: [Matches, Teams, Players])
class MatchDao extends DatabaseAccessor<AppDatabase> with _$MatchDaoMixin {
  MatchDao(super.db);

  // 매치 삽입 후 첫 번째 매치의 ID 반환 (간단한 구현용)
  Future<int> insertMatches(List<MatchesCompanion> list) async {
    try {
      // 데이터베이스에 매치 삽입
      await batch((b) => b.insertAll(matches, list));

      // 가장 최근에 삽입된 매치의 ID 반환 (임시 방편으로, 실제 서비스에서는 보완 필요)
      final lastMatch =
          await (select(matches)
                ..orderBy([(m) => OrderingTerm.desc(m.id)])
                ..limit(1))
              .getSingleOrNull();

      return lastMatch?.id ?? -1;
    } catch (e) {
      if (kDebugMode) {
        print('MatchDao: 매치 삽입 중 오류 발생 - $e');
      }
      rethrow;
    }
  }

  // Drift의 Matche 엔티티를 사용하여 쿼리 실행
  Future<List<Matche>> getMatchesByTournament(int tournamentId) {
    return (select(matches)
          ..where((m) => m.tournamentId.equals(tournamentId))
          ..orderBy([(m) => OrderingTerm.asc(m.order)]))
        .get();
  }

  // 특정 ID의 매치 조회
  Future<Matche?> getMatch(int matchId) {
    return (select(matches)
      ..where((m) => m.id.equals(matchId))).getSingleOrNull();
  }

  // 도메인 모델로 변환하는 메서드
  Future<List<domain.MatchModel>> fetchMatchesByTournament(
    int tournamentId,
  ) async {
    try {
      // 1. 매치 정보 가져오기
      final dbMatches = await getMatchesByTournament(tournamentId);
      final result = <domain.MatchModel>[];

      // 2. 각 매치에 대해 도메인 모델 생성
      for (final dbMatch in dbMatches) {
        // 3. 매치 도메인 모델 생성
        final domainMatch = domain.MatchModel(
          id: dbMatch.id,
          tournamentId: dbMatch.tournamentId,
          playerA: dbMatch.playerA,
          playerB: dbMatch.playerB,
          playerC: dbMatch.playerC,
          playerD: dbMatch.playerD,
          scoreA: dbMatch.scoreA,
          scoreB: dbMatch.scoreB,
          order: dbMatch.order,
        );

        result.add(domainMatch);
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('MatchDao: 토너먼트 매치 조회 중 오류 발생 - $e');
      }
      rethrow;
    }
  }

  Future<void> updateScore({
    required int matchId,
    required int scoreA,
    required int scoreB,
  }) => (update(matches)..where(
    (m) => m.id.equals(matchId),
  )).write(MatchesCompanion(scoreA: Value(scoreA), scoreB: Value(scoreB)));

  // 매치 삭제
  Future<int> deleteMatch(int matchId) {
    return (delete(matches)..where((m) => m.id.equals(matchId))).go();
  }
}
