import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/team_repository.dart';
import 'package:flutter/foundation.dart';

/// 모든 팀 목록을 조회하는 UseCase
class GetAllTeamsUseCase {
  final TeamRepository _teamRepository;

  GetAllTeamsUseCase(this._teamRepository);

  /// 모든 팀 목록 조회 실행
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 팀 목록,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<List<dynamic>>> execute() async {
    try {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllTeamsUseCase: 모든 팀 목록 조회 시도');
      }

      // 레포지토리 호출
      final result = await _teamRepository.fetchTeamsWithPlayers();

      // 디버그 로그
      if (kDebugMode) {
        if (result.isSuccess) {
          print('GetAllTeamsUseCase: 팀 목록 ${result.value.length}개 조회 성공');
        } else {
          print('GetAllTeamsUseCase: 팀 목록 조회 실패 - ${result.error}');
        }
      }

      // 성공 시 그대로 반환
      if (result.isSuccess) {
        return result;
      }

      return Result.failure(result.error);
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllTeamsUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        TeamError(
          message: '팀 목록을 조회하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 