import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/match_repository.dart';
import 'package:flutter/foundation.dart';

/// 매치 삭제 UseCase
class DeleteMatchUseCase {
  final MatchRepository _matchRepository;

  DeleteMatchUseCase(this._matchRepository);

  /// 매치 삭제 실행
  /// 
  /// [matchId]는 삭제할 매치의 ID입니다.
  /// 
  /// 반환값: 성공 시 [Result.successVoid],
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<Unit>> execute(int matchId) async {
    try {
      // 유효성 검증
      if (matchId <= 0) {
        return Result.failure(
          TournamentError(message: '유효하지 않은 매치 ID입니다.'),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print('DeleteMatchUseCase: 매치 삭제 시도 - ID: $matchId');
      }

      // 매치 삭제 요청
      final result = await _matchRepository.deleteMatch(matchId);

      // 디버그 로그
      if (kDebugMode) {
        print('DeleteMatchUseCase: 매치 레포지토리 응답 - $result');
      }

      // 결과 반환
      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('DeleteMatchUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        TournamentError(
          message: '매치를 삭제하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 