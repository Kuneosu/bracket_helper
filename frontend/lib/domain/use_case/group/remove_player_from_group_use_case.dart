import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
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
          GroupError(message: '유효하지 않은 선수 ID입니다.'),
        );
      }

      if (groupId <= 0) {
        return Result.failure(
          GroupError(message: '유효하지 않은 그룹 ID입니다.'),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print('RemovePlayerFromGroupUseCase: 그룹에서 선수 제거 시도 - 선수 ID: $playerId, 그룹 ID: $groupId');
      }

      // 레포지토리 호출
      final result = await _groupRepository.removePlayerFromGroup(playerId, groupId);

      // 디버그 로그
      if (kDebugMode) {
        if (result.isSuccess) {
          print('RemovePlayerFromGroupUseCase: 그룹에서 선수 제거 성공 - 영향받은 행: ${result.value}');
        } else {
          print('RemovePlayerFromGroupUseCase: 그룹에서 선수 제거 실패 - ${result.error}');
        }
      }

      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('RemovePlayerFromGroupUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        GroupError(
          message: '그룹에서 선수를 제거하는 중 오류가 발생했습니다.',
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
      message: '선수를 찾을 수 없습니다${detail != null ? ": $detail" : ""}',
    );
  }
} 