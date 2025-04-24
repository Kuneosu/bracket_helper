import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:bracket_helper/domain/repository/player_repository.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:flutter/foundation.dart';

/// 그룹에 선수를 추가하기 위한 파라미터 클래스
class AddPlayerToGroupParams {
  final int groupId;
  final String playerName;

  AddPlayerToGroupParams({
    required this.groupId,
    required this.playerName,
  });
}

/// 선수를 그룹에 추가하는 UseCase
class AddPlayerToGroupUseCase {
  final GroupRepository _groupRepository;
  final PlayerRepository _playerRepository;

  AddPlayerToGroupUseCase(this._groupRepository, this._playerRepository);

  /// 새 선수를 생성하고 그룹에 추가
  /// 
  /// 성공 시 플레이어 ID를 반환하고, 실패 시 에러 메시지를 반환합니다.
  Future<dynamic> execute(AddPlayerToGroupParams params) async {
    if (kDebugMode) {
      print('UseCase: 선수(이름: ${params.playerName})를 그룹(ID: ${params.groupId})에 추가 시도');
    }
    
    try {
      // 1. 먼저 플레이어 생성
      final playerCompanion = PlayersCompanion.insert(
        name: params.playerName,
      );
      
      // PlayerRepository를 사용하여 플레이어 추가
      final playerResult = await _playerRepository.addPlayer(playerCompanion);
      
      if (playerResult.isFailure) {
        if (kDebugMode) {
          print('UseCase: 선수 생성 실패 - ${playerResult.error.message}');
        }
        return playerResult.error.message;
      }
      
      final playerId = playerResult.value;
      if (kDebugMode) {
        print('UseCase: 선수 생성 완료 - ID: $playerId');
      }
      
      // 2. 그룹에 플레이어 추가
      final addResult = await addExistingPlayerToGroup(playerId, params.groupId);
      
      if (addResult is String) {
        // 에러가 발생한 경우
        return addResult;
      }
      
      return playerId; // 성공 시 플레이어 ID 반환
    } catch (e) {
      // 예상치 못한 예외 처리
      if (kDebugMode) {
        print('UseCase: 예상치 못한 예외 발생 - $e');
      }
      return '선수 추가 중 오류 발생: $e';
    }
  }
  
  /// 기존 선수를 그룹에 추가
  ///
  /// 성공 시 true를 반환하고, 실패 시 에러 메시지를 반환합니다.
  Future<dynamic> addExistingPlayerToGroup(int playerId, int groupId) async {
    if (kDebugMode) {
      print('UseCase: 기존 선수(ID: $playerId)를 그룹(ID: $groupId)에 추가 시도');
    }
    
    try {
      final Result result = await _groupRepository.addPlayerToGroup(playerId, groupId);
      
      if (result.isSuccess) {
        if (kDebugMode) {
          print('UseCase: 선수 추가 성공 - ID: $playerId');
        }
        return true; // 성공 시 true 반환
      } else {
        final error = result.error;
        String errorMessage;
        
        if (error is GroupError) {
          errorMessage = error.message;
        } else {
          errorMessage = '선수 추가 실패: ${error.message}';
        }
        
        if (kDebugMode) {
          print('UseCase: 오류 발생 - $errorMessage');
        }
        
        return errorMessage;
      }
    } catch (e) {
      // 예상치 못한 예외 처리
      if (kDebugMode) {
        print('UseCase: 예상치 못한 예외 발생 - $e');
      }
      return '선수 추가 중 오류 발생: $e';
    }
  }
} 