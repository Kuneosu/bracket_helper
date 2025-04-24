import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/foundation.dart';

/// 그룹에서 선수 제거 UseCase
class RemovePlayerFromGroupUseCase {
  final GroupRepository _groupRepository;

  RemovePlayerFromGroupUseCase(this._groupRepository);

  /// 그룹에서 선수 제거 실행
  ///
  /// [playerId] 제거할 선수 ID
  /// [groupId] 대상 그룹 ID
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 영향받은 행 수,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<int>> execute(int playerId, int groupId) async {
    try {
      // 유효성 검증
      if (playerId <= 0) {
        return Result.failure(
          GroupError(message: AppStrings.invalidPlayerId),
        );
      }

      if (groupId <= 0) {
        return Result.failure(
          GroupError(message: AppStrings.invalidGroupId),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print(AppStrings.removePlayerAttempt.replaceAll('{0}', playerId.toString()).replaceAll('{1}', groupId.toString()));
      }

      // 레포지토리 호출
      final result = await _groupRepository.removePlayerFromGroup(playerId, groupId);

      // 디버그 로그
      if (kDebugMode) {
        if (result.isSuccess) {
          print(AppStrings.removePlayerSuccess.replaceAll('{0}', result.value.toString()));
        } else {
          print(AppStrings.removePlayerFail.replaceAll('{0}', result.error.toString()));
        }
      }

      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print(AppStrings.exceptionOccurred.replaceAll('{0}', e.toString()));
      }

      return Result.failure(
        GroupError(
          message: AppStrings.removePlayerError,
          cause: e,
        ),
      );
    }
  }
}

/// 그룹 관련 오류
class GroupError extends AppError {
  GroupError({required super.message, super.cause});
  
  factory GroupError.playerNotFound({String? detail}) {
    return GroupError(
      message: '${AppStrings.playerNotFound}${detail != null ? ": $detail" : ""}',
    );
  }
} 