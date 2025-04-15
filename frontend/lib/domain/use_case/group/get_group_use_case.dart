import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:flutter/foundation.dart';

/// 특정 그룹의 정보를 가져오는 UseCase
class GetGroupUseCase {
  final GroupRepository _groupRepository;

  GetGroupUseCase(this._groupRepository);

  /// 그룹 ID로 그룹 정보와 소속 선수 목록을 함께 조회
  /// 
  /// [groupId]는 조회할 그룹의 ID입니다.
  /// 
  /// 반환값: 성공 시 [Result.success]와 함께 그룹 및 선수 정보,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<GroupWithPlayers>> execute(int groupId) async {
    try {
      // 유효성 검증
      if (groupId <= 0) {
        return Result.failure(
          GroupError(message: '유효하지 않은 그룹 ID입니다.'),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print('GetGroupUseCase: 그룹 정보 조회 시도 - ID: $groupId');
      }

      // 모든 그룹 목록 조회
      final groupsResult = await _groupRepository.fetchAllGroups();
      if (groupsResult.isFailure) {
        return Result.failure(groupsResult.error);
      }

      // 요청한 ID의 그룹 찾기
      final groups = groupsResult.value;
      final group = groups.where((g) => g.id == groupId).toList();

      if (group.isEmpty) {
        return Result.failure(
          GroupError(message: '해당 ID의 그룹을 찾을 수 없습니다.'),
        );
      }

      // 그룹에 속한 선수 목록 조회
      final playersResult = await _groupRepository.fetchPlayersInGroup(groupId);
      if (playersResult.isFailure) {
        return Result.failure(playersResult.error);
      }

      // 그룹과 선수 정보를 합쳐서 반환
      final groupWithPlayers = GroupWithPlayers(
        group: group.first,
        players: playersResult.value,
      );

      // 디버그 로그
      if (kDebugMode) {
        print('GetGroupUseCase: 그룹 정보 조회 성공 - ${group.first.name}, 선수 ${playersResult.value.length}명');
      }

      return Result.success(groupWithPlayers);
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('GetGroupUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        GroupError(
          message: '그룹 정보를 조회하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
}

/// 그룹과 소속 선수 정보를 함께 담는 모델 클래스
class GroupWithPlayers {
  final Group group;
  final List<Player> players;

  GroupWithPlayers({
    required this.group,
    required this.players,
  });
} 