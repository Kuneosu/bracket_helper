import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/group_dao.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:flutter/foundation.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupDao _groupDao;

  GroupRepositoryImpl(this._groupDao);

  @override
  Future<Result<List<Group>>> fetchAllGroups() async {
    try {
      final groups = await _groupDao.fetchAllGroups();
      return Result.success(groups);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '그룹 목록을 불러오는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<int>> addGroup(GroupsCompanion group) async {
    try {
      final id = await _groupDao.insertGroup(group);
      return Result.success(id);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '그룹을 추가하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> addPlayerToGroup(int playerId, int groupId) async {
    try {
      if (kDebugMode) {
        print('Repository: 선수(ID: $playerId)를 그룹(ID: $groupId)에 추가 시도');
      }
      await _groupDao.addPlayerToGroup(playerId, groupId);
      if (kDebugMode) {
        print('Repository: 선수 추가 성공');
      }
      return Result.successVoid as Result<void>;
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }
      
      // SQLite 예외 코드 확인 (제약 조건 위반)
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('unique constraint failed') || 
          errorString.contains('sqlite_constraint') ||
          errorString.contains('constraint violation')) {
        return Result.failure(
          GroupError.playerAlreadyExists(
            cause: e,
          ),
        );
      }
      
      return Result.failure(
        DatabaseError(
          message: '선수를 그룹에 추가하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<Player>>> fetchPlayersInGroup(int groupId) async {
    try {
      final players = await _groupDao.fetchPlayersInGroup(groupId);
      return Result.success(players);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '그룹 내 선수 목록을 불러오는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<int>> deleteGroup(int groupId) async {
    try {
      final result = await _groupDao.deleteGroup(groupId);
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '그룹을 삭제하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<int>> removePlayerFromGroup(int playerId, int groupId) async {
    try {
      final result = await _groupDao.removePlayerFromGroup(playerId, groupId);
      if (result == 0) {
        // 삭제된 레코드가 없으면 해당 관계가 없는 것
        return Result.failure(
          GroupError.playerNotFound(
            detail: '해당 선수가 그룹에 존재하지 않습니다.',
          ),
        );
      }
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '그룹에서 선수를 제거하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }
} 