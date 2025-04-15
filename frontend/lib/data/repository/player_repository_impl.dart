import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/player_dao.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/player_repository.dart';
import 'package:flutter/foundation.dart';

/// PlayerRepository 구현체
class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerDao _playerDao;

  PlayerRepositoryImpl(this._playerDao);

  @override
  Future<Result<int>> addPlayer(PlayersCompanion player) async {
    try {
      if (kDebugMode) {
        print('Repository: 선수 추가 시도 - 이름: ${player.name.value}');
      }
      final playerId = await _playerDao.upsertPlayer(player);
      if (kDebugMode) {
        print('Repository: 선수 추가 성공 - ID: $playerId');
      }
      return Result.success(playerId);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }
      
      return Result.failure(
        DatabaseError(
          message: '선수를 추가하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deletePlayer(int playerId) async {
    try {
      if (kDebugMode) {
        print('Repository: 선수 삭제 시도 - ID: $playerId');
      }
      await _playerDao.deletePlayer(playerId);
      if (kDebugMode) {
        print('Repository: 선수 삭제 성공');
      }
      return Result.successVoid as Result<void>;
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }
      
      return Result.failure(
        DatabaseError(
          message: '선수를 삭제하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<Player>>> fetchAllPlayers() async {
    try {
      final players = await _playerDao.fetchAllPlayers();
      return Result.success(players);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '선수 목록을 불러오는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<Player?>> getPlayer(int playerId) async {
    try {
      final player = await _playerDao.getPlayer(playerId);
      return Result.success(player);
    } catch (e) {
      return Result.failure(
        DatabaseError(
          message: '선수 정보를 불러오는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<int>> updatePlayer(PlayersCompanion player) async {
    try {
      if (kDebugMode) {
        print('Repository: 선수 정보 업데이트 시도 - 이름: ${player.name.value}');
      }
      final playerId = await _playerDao.upsertPlayer(player);
      if (kDebugMode) {
        print('Repository: 선수 정보 업데이트 성공 - ID: $playerId');
      }
      return Result.success(playerId);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: 예외 발생 - $e');
      }
      
      return Result.failure(
        DatabaseError(
          message: '선수 정보를 업데이트하는데 실패했습니다.',
          cause: e,
        ),
      );
    }
  }
} 