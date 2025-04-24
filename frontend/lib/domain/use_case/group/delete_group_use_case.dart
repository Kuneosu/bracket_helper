import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:flutter/foundation.dart';

/// 그룹 삭제 UseCase
class DeleteGroupUseCase {
  final GroupRepository _groupRepository;

  DeleteGroupUseCase(this._groupRepository);

  /// 그룹 삭제 실행
  /// 
  /// [groupId]는 삭제할 그룹의 ID입니다.
  /// 
  /// 반환값: 성공 시 삭제된 행 수를 포함한 [Result.success],
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<int>> execute(int groupId) async {
    try {
      // 유효성 검증
      if (groupId <= 0) {
        return Result.failure(
          GroupError(message: '유효하지 않은 그룹 ID입니다.'),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print('DeleteGroupUseCase: 그룹 삭제 시도 - ID: $groupId');
      }

      // 그룹 삭제 요청
      final result = await _groupRepository.deleteGroup(groupId);

      // 디버그 로그
      if (kDebugMode) {
        print('DeleteGroupUseCase: 그룹 레포지토리 응답 - $result');
      }

      // 결과 전달 (Repository에서 이미 Result 타입을 반환하므로 그대로 전달)
      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('DeleteGroupUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        GroupError(
          message: '그룹을 삭제하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 