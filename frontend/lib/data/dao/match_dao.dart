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
      // 디버그 로그 추가
      if (kDebugMode) {
        print('MatchDao: 매치 삽입 시작 - ${list.length}개 항목');
        for (int i = 0; i < list.length; i++) {
          final item = list[i];
          print('MatchDao: 삽입 항목 #${i+1} - Order: ${item.ord.value}, A: ${item.playerA.value}');
        }
      }
      
      // ID를 제외한 필드만 가져와서 새로운 리스트 생성하여 자동 증가 ID 사용
      final validList = list.map((item) {
        // ID 필드를 제외하고 새로운 MatchesCompanion 객체 생성
        return MatchesCompanion(
          tournamentId: item.tournamentId,
          ord: item.ord,
          playerA: item.playerA,
          playerB: item.playerB,
          playerC: item.playerC,
          playerD: item.playerD,
          // 점수가 지정되지 않은 경우 기본값 0으로 설정
          scoreA: item.scoreA.present ? item.scoreA : const Value(0),
          scoreB: item.scoreB.present ? item.scoreB : const Value(0),
        );
      }).toList();
      
      // 데이터베이스에 매치 삽입 (ID는 자동으로 증가)
      final insertedIds = <int>[];
      for (final item in validList) {
        // 개별적으로 삽입하고 생성된 ID 추적
        final id = await into(matches).insert(item);
        insertedIds.add(id);
        if (kDebugMode) {
          print('MatchDao: 매치 삽입 성공 - 생성된 ID: $id, 순서: ${item.ord.value}');
        }
      }
      
      // 마지막으로 삽입된 ID 반환 또는 대안으로 첫 번째 ID 반환
      if (insertedIds.isNotEmpty) {
        if (kDebugMode) {
          print('MatchDao: 총 ${insertedIds.length}개 매치 삽입 완료, 첫 번째 ID: ${insertedIds.first}');
        }
        return insertedIds.first;
      }
      
      // 이전 방식으로 ID 조회 (백업 방식)
      final lastMatch =
          await (select(matches)
                ..orderBy([(m) => OrderingTerm.desc(m.id)])
                ..limit(1))
              .getSingleOrNull();

      if (kDebugMode) {
        print('MatchDao: 최근 생성된 매치 ID: ${lastMatch?.id}');
      }
      return lastMatch?.id ?? -1;
    } catch (e) {
      if (kDebugMode) {
        print('MatchDao: 매치 삽입 중 오류 발생 - $e');
      }
      rethrow;
    }
  }

  // Drift의 Matche 엔티티를 사용하여 쿼리 실행 - SQL 직접 사용
  Future<List<Matche>> getMatchesByTournament(int tournamentId) async {
    if (kDebugMode) {
      print('MatchDao: 토너먼트($tournamentId) 매치 조회 시작');
    }
    
    // ord 컬럼으로 정렬
    final query = customSelect(
      'SELECT * FROM matches WHERE tournament_id = ? ORDER BY ord ASC;',
      variables: [Variable.withInt(tournamentId)],
    );
    
    // 결과를 Matche 객체로 변환
    final rows = await query.get();
    final matches = rows.map((row) {
      return Matche(
        id: row.read<int>('id'),
        tournamentId: row.read<int>('tournament_id'),
        ord: row.read<int>('ord'),
        playerA: row.readNullable<String>('player_a'),
        playerB: row.readNullable<String>('player_b'),
        playerC: row.readNullable<String>('player_c'),
        playerD: row.readNullable<String>('player_d'),
        scoreA: row.readNullable<int>('score_a'),
        scoreB: row.readNullable<int>('score_b'),
      );
    }).toList();
    
    if (kDebugMode) {
      print('MatchDao: 토너먼트($tournamentId) 매치 ${matches.length}개 조회 성공');
    }
    
    return matches;
  }

  // 특정 ID의 매치 조회
  Future<Matche?> getMatch(int matchId) async {
    if (kDebugMode) {
      print('MatchDao: ID $matchId 매치 조회 시작');
    }
    
    try {
      // 모든 매치 조회하여 로그로 확인 (디버깅 용도)
      if (kDebugMode) {
        final allMatches = await select(matches).get();
        print('MatchDao: 데이터베이스에 ${allMatches.length}개 매치 존재');
        for (final m in allMatches) {
          print('MatchDao: 매치 정보 - ID: ${m.id}, Ord: ${m.ord}, A: ${m.playerA}');
        }
      }
      
      // 지정된 ID의 매치 조회
      final result = await (select(matches)
        ..where((m) => m.id.equals(matchId))).getSingleOrNull();
      
      if (kDebugMode) {
        if (result != null) {
          print('MatchDao: 매치 조회 성공 - ID: ${result.id}, Ord: ${result.ord}');
        } else {
          print('MatchDao: 매치 조회 실패 - ID $matchId 없음');
        }
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('MatchDao: 매치 조회 중 오류 발생 - $e');
      }
      return null;
    }
  }

  // 토너먼트별 매치 조회 (도메인 모델로 변환)
  Future<List<domain.MatchModel>> fetchMatchesByTournament(int tournamentId) async {
    try {
      if (kDebugMode) {
        print('MatchDao: 토너먼트($tournamentId) 매치 조회 시작 (도메인 모델 변환)');
      }
      
      // 데이터베이스 매치 레코드 가져오기
      final matchRecords = await getMatchesByTournament(tournamentId);
      
      // 도메인 모델로 변환
      return matchRecords.map((matche) => domain.MatchModel(
        id: matche.id,
        tournamentId: matche.tournamentId,
        ord: matche.ord,
        playerA: matche.playerA,
        playerB: matche.playerB,
        playerC: matche.playerC,
        playerD: matche.playerD,
        scoreA: matche.scoreA,
        scoreB: matche.scoreB,
      )).toList();
    } catch (e) {
      if (kDebugMode) {
        print('MatchDao: 토너먼트($tournamentId) 매치 조회 실패 - $e');
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

  // 토너먼트 ID로 모든 매치 삭제
  Future<int> deleteMatchesByTournamentId(int tournamentId) async {
    if (kDebugMode) {
      print('MatchDao: 토너먼트($tournamentId)의 모든 매치 삭제 시작');
    }
    try {
      final result = await (delete(matches)..where((m) => m.tournamentId.equals(tournamentId))).go();
      if (kDebugMode) {
        print('MatchDao: 토너먼트($tournamentId)의 매치 $result개 삭제 완료');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('MatchDao: 토너먼트($tournamentId) 매치 삭제 중 오류 발생 - $e');
      }
      rethrow;
    }
  }

  // Drift의 Matche 엔티티를 사용하여 모든 매치 조회 - SQL 직접 사용
  Future<List<Matche>> getAllMatches() async {
    if (kDebugMode) {
      print('MatchDao: 모든 매치 조회 시작');
    }
    
    // 직접 SQL 쿼리 작성 - tournament_id, ord로 정렬
    final query = customSelect(
      'SELECT * FROM matches ORDER BY tournament_id ASC, ord ASC;',
    );
    
    // 결과를 Matche 객체로 변환
    final rows = await query.get();
    final matches = rows.map((row) {
      return Matche(
        id: row.read<int>('id'),
        tournamentId: row.read<int>('tournament_id'),
        ord: row.read<int>('ord'),
        playerA: row.readNullable<String>('player_a'),
        playerB: row.readNullable<String>('player_b'),
        playerC: row.readNullable<String>('player_c'),
        playerD: row.readNullable<String>('player_d'),
        scoreA: row.readNullable<int>('score_a'),
        scoreB: row.readNullable<int>('score_b'),
      );
    }).toList();
    
    if (kDebugMode) {
      print('MatchDao: 모든 매치 ${matches.length}개 조회 성공');
    }
    
    return matches;
  }

  // 모든 매치를 도메인 모델로 변환
  Future<List<domain.MatchModel>> fetchAllMatches() async {
    try {
      // 1. 모든 매치 정보 가져오기
      final dbMatches = await getAllMatches();
      final result = <domain.MatchModel>[];

      if (kDebugMode) {
        print('MatchDao: 전체 매치 ${dbMatches.length}개 조회됨');
      }

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
          ord: dbMatch.ord,
        );

        result.add(domainMatch);
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('MatchDao: 전체 매치 조회 중 오류 발생 - $e');
      }
      rethrow;
    }
  }
}
