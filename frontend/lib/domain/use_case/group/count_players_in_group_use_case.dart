import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:flutter/foundation.dart';

/// 그룹 내 선수 수를 조회하는 UseCase
class CountPlayersInGroupUseCase {
  final GroupRepository _groupRepository;

  CountPlayersInGroupUseCase(this._groupRepository);

  /// 특정 그룹에 속한 선수 수 조회
  ///
  /// [groupId] 조회할 그룹의 ID
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 선수 수,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<int>> execute(int groupId) async {
    if (kDebugMode) {
      print('CountPlayersInGroupUseCase: 그룹(ID: $groupId) 내 선수 수 조회 시도');
    }

    try {
      // 그룹 ID 유효성 검사
      if (groupId <= 0) {
        return Result.failure(
          GroupError(message: '유효하지 않은 그룹 ID입니다.'),
        );
      }

      // 레포지토리 호출하여 선수 수 조회
      final result = await _groupRepository.countPlayersInGroup(groupId);

      if (result.isSuccess) {
        final count = result.value;
        if (kDebugMode) {
          print('CountPlayersInGroupUseCase: 그룹(ID: $groupId) 내 선수 수: $count');
        }
        return Result.success(count);
      } else {
        if (kDebugMode) {
          print('CountPlayersInGroupUseCase: 선수 수 조회 실패 - ${result.error.message}');
        }
        return Result.failure(result.error);
      }
    } catch (e) {
      // 예상치 못한 예외 처리
      if (kDebugMode) {
        print('CountPlayersInGroupUseCase: 예상치 못한 예외 발생 - $e');
      }
      
      return Result.failure(
        GroupError(
          message: '그룹 내 선수 수 조회 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 