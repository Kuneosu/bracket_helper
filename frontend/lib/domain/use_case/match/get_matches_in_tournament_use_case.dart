import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match_model.dart' as domain;
import 'package:bracket_helper/domain/repository/tournament_repository.dart';
import 'package:flutter/foundation.dart';

/// 토너먼트 내 매치 조회 UseCase
class GetMatchesInTournamentUseCase {
  final TournamentRepository _tournamentRepository;

  GetMatchesInTournamentUseCase(this._tournamentRepository);

  /// 특정 토너먼트 내 모든 매치 조회 실행
  ///
  /// [tournamentId] 매치를 조회할 토너먼트 ID
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 매치 목록,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<List<domain.MatchModel>>> execute(int tournamentId) async {
    try {
      // 유효성 검증
      if (tournamentId <= 0) {
        return Result.failure(
          TournamentError(message: '유효하지 않은 토너먼트 ID입니다.'),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print('GetMatchesInTournamentUseCase: 토너먼트 내 매치 조회 시도 - 토너먼트 ID: $tournamentId');
      }

      // 토너먼트 존재 여부 확인
      final tournamentResult = await _tournamentRepository.getTournament(tournamentId);
      
      if (tournamentResult.isFailure) {
        if (kDebugMode) {
          print('GetMatchesInTournamentUseCase: 토너먼트 조회 실패 - ${tournamentResult.error}');
        }
        return Result.failure(
          TournamentError(message: '토너먼트 정보를 조회할 수 없습니다.', cause: tournamentResult.error),
        );
      }
      
      if (tournamentResult.value == null) {
        if (kDebugMode) {
          print('GetMatchesInTournamentUseCase: 존재하지 않는 토너먼트 - ID: $tournamentId');
        }
        return Result.failure(
          TournamentError(message: '존재하지 않는 토너먼트입니다.'),
        );
      }

      // 토너먼트 내 매치 조회
      final result = await _tournamentRepository.fetchMatchesByTournament(tournamentId);

      // 디버그 로그
      if (kDebugMode) {
        if (result.isSuccess) {
          print('GetMatchesInTournamentUseCase: 매치 조회 성공 - 총 ${result.value.length}개');
        } else {
          print('GetMatchesInTournamentUseCase: 매치 조회 실패 - ${result.error}');
        }
      }

      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('GetMatchesInTournamentUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        TournamentError(
          message: '토너먼트 내 매치를 조회하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
}

/// 토너먼트 관련 오류
class TournamentError extends AppError {
  TournamentError({required super.message, super.cause});
} 