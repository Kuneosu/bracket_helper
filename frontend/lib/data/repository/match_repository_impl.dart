import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/match_dao.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match_model.dart' as domain;
import 'package:bracket_helper/domain/repository/match_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

/// 매치 관련 Repository 구현체
class MatchRepositoryImpl implements MatchRepository {
  final MatchDao _matchDao;

  MatchRepositoryImpl(this._matchDao);

  @override
  Future<Result<domain.MatchModel>> createMatch({
    required int tournamentId,
    String? playerA,
    String? playerB,
    String? playerC,
    String? playerD,
    int order = 0,
  }) async {
    try {
      if (playerA == null || playerB == null) {
        return Result.failure(
          ValidationError(message: '매치 생성에 필요한 선수 정보가 부족합니다.'),
        );
      }

      // 매치 정보 생성 (order 파라미터로 설정)
      final match = MatchesCompanion(
        tournamentId: Value(tournamentId),
        playerA: Value(playerA),
        playerB: Value(playerB),
        playerC: Value(playerC),
        playerD: Value(playerD),
        ord: Value(order),
        // 기본 점수 추가
        scoreA: const Value(0),
        scoreB: const Value(0),
      );

      // 매치 저장
      final matchId = await _matchDao.insertMatches([match]);

      // 이 부분이 중요: 저장된 매치를 다시 조회하여 실제 DB에 저장된 정보를 가져옴
      final savedMatch = await _matchDao.getMatch(matchId);
      
      if (savedMatch == null) {
        return Result.failure(
          DatabaseError(message: '매치가 저장되었으나 조회에 실패했습니다.'),
        );
      }
      
      if (kDebugMode) {
        print('Repository: 저장된 매치 조회 성공 - ID: ${savedMatch.id}, Ord: ${savedMatch.ord}');
      }

      // 저장된 실제 DB 정보로부터 도메인 객체 생성
      final createdMatch = domain.MatchModel(
        id: savedMatch.id,
        tournamentId: savedMatch.tournamentId,
        playerA: savedMatch.playerA,
        playerB: savedMatch.playerB,
        playerC: savedMatch.playerC,
        playerD: savedMatch.playerD,
        scoreA: savedMatch.scoreA ?? 0,
        scoreB: savedMatch.scoreB ?? 0,
        ord: savedMatch.ord,
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
  Future<Result<List<domain.MatchModel>>> createMatches(
    List<Map<String, dynamic>> matchesData,
  ) async {
    try {
      if (kDebugMode) {
        print('Repository: ${matchesData.length}개의 매치 생성 시도');
      }

      // MatchesCompanion 리스트로 변환
      final matchesCompanions =
          matchesData.map((data) {
            final playerA = data['playerA'] as String?;
            final playerB = data['playerB'] as String?;
            final order = data['order'] as int? ?? 0;

            if (playerA == null || playerB == null) {
              throw ValidationError(message: '매치 생성에 필요한 선수 정보가 없습니다.');
            }

            return MatchesCompanion(
              tournamentId: Value(data['tournamentId'] as int),
              playerA: Value(playerA),
              playerB: Value(playerB),
              playerC: data['playerC'] != null
                  ? Value(data['playerC'] as String)
                  : const Value.absent(),
              playerD: data['playerD'] != null
                  ? Value(data['playerD'] as String)
                  : const Value.absent(),
              ord: Value(order),
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
            return domain.MatchModel(
              id: firstMatchId + index, // 추정 ID (실제로는 다르게 처리 필요)
              tournamentId: data['tournamentId'] as int,
              playerA: data['playerA'] as String?,
              playerB: data['playerB'] as String?,
              playerC: data['playerC'] as String?,
              playerD: data['playerD'] as String?,
              scoreA: data['scoreA'] as int?,
              scoreB: data['scoreB'] as int?,
              ord: order,
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
  Future<Result<List<domain.MatchModel>>> fetchMatchesByTournament(
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
  Future<Result<domain.MatchModel>> updateScore({
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

      final updatedMatch = domain.MatchModel(
        id: matchId,
        tournamentId: updatedDbMatch.tournamentId,
        playerA: updatedDbMatch.playerA,
        playerB: updatedDbMatch.playerB,
        playerC: updatedDbMatch.playerC,
        playerD: updatedDbMatch.playerD,
        scoreA: scoreA,
        scoreB: scoreB,
        ord: updatedDbMatch.ord,
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

  @override
  Future<Result<List<domain.MatchModel>>> fetchAllMatches() async {
    try {
      if (kDebugMode) {
        print('Repository: 모든 매치 목록 조회');
      }
      final matches = await _matchDao.fetchAllMatches();
      if (kDebugMode) {
        print('Repository: 전체 ${matches.length}개 매치 조회 성공');
      }
      return Result.success(matches);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 모든 매치 조회 중 예외 발생 - $e');
      }
      return Result.failure(
        DatabaseError(message: '모든 매치 목록을 불러오는데 실패했습니다.', cause: e),
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
