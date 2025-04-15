import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/team_repository.dart';
import 'package:flutter/foundation.dart';

/// 팀 삭제 UseCase
class DeleteTeamUseCase {
  final TeamRepository _teamRepository;

  DeleteTeamUseCase(this._teamRepository);

  /// 팀 삭제 실행
  /// 
  /// [teamId]는 삭제할 팀의 ID입니다.
  /// 
  /// 반환값: 성공 시 [Result.successVoid],
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<Unit>> execute(int teamId) async {
    try {
      // 유효성 검증
      if (teamId <= 0) {
        return Result.failure(
          TeamError(message: '유효하지 않은 팀 ID입니다.'),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print('DeleteTeamUseCase: 팀 삭제 시도 - ID: $teamId');
      }

      // 팀 삭제 요청
      final result = await _teamRepository.deleteTeam(teamId);

      // 디버그 로그
      if (kDebugMode) {
        print('DeleteTeamUseCase: 팀 레포지토리 응답 - $result');
      }

      // Result<void>를 Result<Unit>으로 변환하여 반환
      if (result.isSuccess) {
        return Result.successVoid;
      } else {
        return Result.failure(result.error);
      }
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('DeleteTeamUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        TeamError(
          message: '팀을 삭제하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 