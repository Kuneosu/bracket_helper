import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/match_dao.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match.dart' as domain;
import 'package:bracket_helper/domain/repository/match_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

/// 매치 관련 Repository 구현체
class MatchRepositoryImpl implements MatchRepository {
  final MatchDao _matchDao;

  MatchRepositoryImpl(this._matchDao);

  @override
  Future<Result<domain.Match>> createMatch({
    required int tournamentId,
    int? teamAId,
    int? teamBId,
    String? teamAName,
    String? teamBName,
  }) async {
    try {
      if (teamAId == null || teamBId == null) {
        return Result.failure(
          ValidationError(message: '매치 생성에 필요한 팀 정보가 부족합니다.'),
        );
      }

      // 매치 정보 생성 (order는 일단 0으로 설정)
      final match = MatchesCompanion(
        tournamentId: Value(tournamentId),
        teamAId: Value(teamAId),
        teamBId: Value(teamBId),
        order: const Value(0),
      );

      // 매치 저장
      final matchId = await _matchDao.insertMatches([match]);

      // 매치 도메인 객체 생성
      final createdMatch = domain.Match(
        id: matchId,
        tournamentId: tournamentId,
        teamAId: teamAId,
        teamBId: teamBId,
        teamAName: teamAName,
        teamBName: teamBName,
        order: 0,
      );

      return Result.success(createdMatch);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 매치 생성 실패 - $e');
      }
      return Result.failure(
        DatabaseError(message: '매치를 생성하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<domain.Match>>> createMatches(
    List<Map<String, dynamic>> matchesData,
  ) async {
    try {
      if (kDebugMode) {
        print('Repository: ${matchesData.length}개의 매치 생성 시도');
      }

      // MatchesCompanion 리스트로 변환
      final matchesCompanions =
          matchesData.map((data) {
            final teamAId = data['teamAId'] as int?;
            final teamBId = data['teamBId'] as int?;
            final order = data['order'] as int? ?? 0;

            if (teamAId == null || teamBId == null) {
              throw ValidationError(message: '매치 생성에 필요한 팀 정보가 없습니다.');
            }

            return MatchesCompanion(
              tournamentId: Value(data['tournamentId'] as int),
              teamAId: Value(teamAId),
              teamBId: Value(teamBId),
              order: Value(order),
              scoreA:
                  data['scoreA'] != null
                      ? Value(data['scoreA'] as int)
                      : const Value.absent(),
              scoreB:
                  data['scoreB'] != null
                      ? Value(data['scoreB'] as int)
                      : const Value.absent(),
            );
          }).toList();

      // 매치 저장 및 ID 획득
      final firstMatchId = await _matchDao.insertMatches(matchesCompanions);

      // 도메인 객체 리스트 생성
      final createdMatches =
          matchesData.mapIndexed((index, data) {
            final order = data['order'] as int? ?? 0;
            return domain.Match(
              id: firstMatchId + index, // 추정 ID (실제로는 다르게 처리 필요)
              tournamentId: data['tournamentId'] as int,
              teamAId: data['teamAId'] as int?,
              teamBId: data['teamBId'] as int?,
              teamAName: data['teamAName'] as String?,
              teamBName: data['teamBName'] as String?,
              scoreA: data['scoreA'] as int?,
              scoreB: data['scoreB'] as int?,
              order: order,
            );
          }).toList();

      if (kDebugMode) {
        print('Repository: 매치 생성 성공');
      }

      return Result.success(createdMatches);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }

      return Result.failure(
        DatabaseError(message: '매치를 생성하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<domain.Match>>> fetchMatchesByTournament(
    int tournamentId,
  ) async {
    try {
      if (kDebugMode) {
        print('Repository: 토너먼트($tournamentId)의 매치 목록 조회');
      }
      final matches = await _matchDao.fetchMatchesByTournament(tournamentId);
      if (kDebugMode) {
        print('Repository: ${matches.length}개의 매치 조회 성공');
      }
      return Result.success(matches);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }

      return Result.failure(
        DatabaseError(message: '매치 목록을 불러오는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<domain.Match>> updateScore({
    required int matchId,
    required int? scoreA,
    required int? scoreB,
  }) async {
    try {
      if (kDebugMode) {
        print('Repository: 매치($matchId) 점수 업데이트 시도 - A: $scoreA, B: $scoreB');
      }

      // 점수 업데이트 (null이 아닌 값만 업데이트)
      await _matchDao.updateScore(
        matchId: matchId,
        scoreA: scoreA ?? 0,
        scoreB: scoreB ?? 0,
      );

      // 매치 조회 및 도메인 객체 생성
      final updatedDbMatch = await _matchDao.getMatch(matchId);

      if (updatedDbMatch == null) {
        return Result.failure(DatabaseError(message: '업데이트된 매치를 찾을 수 없습니다.'));
      }

      final updatedMatch = domain.Match(
        id: matchId,
        tournamentId: updatedDbMatch.tournamentId,
        teamAId: updatedDbMatch.teamAId,
        teamBId: updatedDbMatch.teamBId,
        scoreA: scoreA,
        scoreB: scoreB,
        order: updatedDbMatch.order,
      );

      if (kDebugMode) {
        print('Repository: 점수 업데이트 성공');
      }

      return Result.success(updatedMatch);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }

      return Result.failure(
        DatabaseError(message: '매치 점수를 업데이트하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Unit>> deleteMatch(int matchId) async {
    try {
      if (kDebugMode) {
        print('Repository: 매치($matchId) 삭제 시도');
      }

      // 매치가 존재하는지 확인
      final match = await _matchDao.getMatch(matchId);
      if (match == null) {
        return Result.failure(
          DatabaseError.notFound(detail: '삭제할 매치를 찾을 수 없습니다.'),
        );
      }

      // 매치 삭제
      final deletedCount = await _matchDao.deleteMatch(matchId);

      if (deletedCount <= 0) {
        return Result.failure(DatabaseError(message: '매치 삭제에 실패했습니다.'));
      }

      if (kDebugMode) {
        print('Repository: 매치 삭제 성공');
      }

      return Result.successVoid;
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 매치 삭제 예외 발생 - $e');
      }

      return Result.failure(
        DatabaseError(message: '매치를 삭제하는데 실패했습니다.', cause: e),
      );
    }
  }
}

/// 유효성 검증 오류
class ValidationError extends AppError {
  ValidationError({required super.message, super.cause});
}

/// List에 인덱스 접근할 수 있는 확장 메서드
extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}
