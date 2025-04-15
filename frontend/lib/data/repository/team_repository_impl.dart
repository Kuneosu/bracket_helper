import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/team_dao.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/team_repository.dart';
import 'package:flutter/foundation.dart';

/// 팀 관련 Repository 구현체
class TeamRepositoryImpl implements TeamRepository {
  final TeamDao _teamDao;

  TeamRepositoryImpl(this._teamDao);

  @override
  Future<Result<int>> createTeam(TeamsCompanion team) async {
    try {
      if (kDebugMode) {
        print('Repository: 팀 생성 시도 - 선수1: ${team.player1Id}, 선수2: ${team.player2Id}');
      }
      final teamId = await _teamDao.insertTeam(team);
      if (kDebugMode) {
        print('Repository: 팀 생성 성공 - ID: $teamId');
      }
      return Result.success(teamId);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }
      
      return Result.failure(
        DatabaseError(
          message: '팀을 생성하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteTeam(int teamId) async {
    try {
      if (kDebugMode) {
        print('Repository: 팀 삭제 시도 - ID: $teamId');
      }
      await _teamDao.deleteTeam(teamId);
      if (kDebugMode) {
        print('Repository: 팀 삭제 성공');
      }
      return Result.successVoid as Result<void>;
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }
      
      return Result.failure(
        DatabaseError(
          message: '팀을 삭제하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<Team>>> fetchAllTeams() async {
    try {
      final teams = await _teamDao.fetchAllTeams();
      return Result.success(teams);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '팀 목록을 불러오는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<dynamic>>> fetchTeamsWithPlayers() async {
    try {
      final teamsWithPlayers = await _teamDao.fetchTeamsWithPlayers();
      return Result.success(teamsWithPlayers);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '팀과 선수 정보를 불러오는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<Team?>> getTeam(int teamId) async {
    try {
      final team = await _teamDao.getTeam(teamId);
      return Result.success(team);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '팀 정보를 불러오는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }
} 