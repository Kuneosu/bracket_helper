import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/tournament_repository.dart';
import 'package:flutter/foundation.dart';

/// 토너먼트 삭제 UseCase
class DeleteTournamentUseCase {
  final TournamentRepository _tournamentRepository;

  DeleteTournamentUseCase(this._tournamentRepository);

  /// 토너먼트 삭제 실행
  ///
  /// [tournamentId]는 삭제할 토너먼트의 ID입니다.
  ///
  /// 반환값: 성공 시 [Result.successVoid],
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<Unit>> execute(int tournamentId) async {
    try {
      // 유효성 검증
      if (tournamentId <= 0) {
        return Result.failure(TournamentError(message: '유효하지 않은 토너먼트 ID입니다.'));
      }

      // 디버그 로그
      if (kDebugMode) {
        print('DeleteTournamentUseCase: 토너먼트 삭제 시도 - ID: $tournamentId');
      }

      // 토너먼트 존재 여부 확인
      final tournament = await _tournamentRepository.getTournament(
        tournamentId,
      );
      if (tournament.isFailure) {
        return Result.failure(TournamentError(message: '존재하지 않는 토너먼트입니다.'));
      }

      // 토너먼트 삭제 요청
      final deleteResult = await _tournamentRepository.deleteTournament(tournamentId);
      
      // 삭제 결과 확인
      if (deleteResult.isFailure) {
        // 디버그 로그
        if (kDebugMode) {
          print('DeleteTournamentUseCase: 토너먼트 삭제 실패 - ID: $tournamentId, 오류: ${deleteResult.error.message}');
        }
        return Result.failure(deleteResult.error);
      }

      // 디버그 로그
      if (kDebugMode) {
        print('DeleteTournamentUseCase: 토너먼트 삭제 성공 - ID: $tournamentId');
      }

      return Result.successVoid;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('DeleteTournamentUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        TournamentError(message: '토너먼트를 삭제하는 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
