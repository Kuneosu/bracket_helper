import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/team_dao.dart';
import 'package:bracket_helper/data/dao/player_dao.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/team_model.dart';
import 'package:bracket_helper/domain/repository/team_repository.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:flutter/foundation.dart';

/// 팀 관련 Repository 구현체
class TeamRepositoryImpl implements TeamRepository {
  final TeamDao _teamDao;
  final PlayerDao _playerDao;

  TeamRepositoryImpl(this._teamDao, this._playerDao);

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
  Future<Result<List<TeamModel>>> fetchAllTeams() async {
    try {
      final teams = await _teamDao.fetchAllTeams();
      // Team 객체를 TeamModel로 변환
      final teamModels = await Future.wait(teams.map((team) async {
        final player1 = await _playerDao.getPlayer(team.player1Id);
        Player? player2;
        if (team.player2Id != null) {
          player2 = await _playerDao.getPlayer(team.player2Id!);
        }
        
        if (player1 == null) {
          throw Exception('Player with ID ${team.player1Id} not found');
        }
        
        final playerModel1 = PlayerModel(
          id: player1.id,
          name: player1.name,
        );
        
        PlayerModel? playerModel2;
        if (player2 != null) {
          playerModel2 = PlayerModel(
            id: player2.id,
            name: player2.name,
          );
        }
        
        return TeamModel(playerModel1, playerModel2);
      }));
      
      return Result.success(teamModels);
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
  Future<Result<List<TeamModel>>> fetchTeamsWithPlayers() async {
    try {
      final teamsWithPlayers = await _teamDao.fetchTeamsWithPlayers();
      // TeamWithPlayers 객체를 TeamModel로 변환
      final teamModels = teamsWithPlayers.map((teamWithPlayers) {
        final player1Model = PlayerModel(
          id: teamWithPlayers.player1.id,
          name: teamWithPlayers.player1.name,
        );
        
        PlayerModel? player2Model;
        if (teamWithPlayers.player2 != null) {
          player2Model = PlayerModel(
            id: teamWithPlayers.player2!.id,
            name: teamWithPlayers.player2!.name,
          );
        }
        
        return TeamModel(player1Model, player2Model);
      }).toList();
      
      return Result.success(teamModels);
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
  Future<Result<TeamModel?>> getTeam(int teamId) async {
    try {
      final team = await _teamDao.getTeam(teamId);
      
      if (team == null) {
        return Result.success(null);
      }
      
      // Team 객체를 TeamModel로 변환
      final player1 = await _playerDao.getPlayer(team.player1Id);
      Player? player2;
      if (team.player2Id != null) {
        player2 = await _playerDao.getPlayer(team.player2Id!);
      }
      
      if (player1 == null) {
        throw Exception('Player with ID ${team.player1Id} not found');
      }
      
      final playerModel1 = PlayerModel(
        id: player1.id,
        name: player1.name,
      );
      
      PlayerModel? playerModel2;
      if (player2 != null) {
        playerModel2 = PlayerModel(
          id: player2.id,
          name: player2.name,
        );
      }
      
      return Result.success(TeamModel(playerModel1, playerModel2));
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