import 'package:bracket_helper/domain/repository/player_repository.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// 선수 정보 업데이트를 위한 UseCase
class UpdatePlayerUseCase {
  final PlayerRepository _playerRepository;

  UpdatePlayerUseCase(this._playerRepository);

  /// 선수 정보를 업데이트하는 함수
  ///
  /// [playerId]는 업데이트할 선수의 ID입니다.
  /// [name]은 변경할 선수의 이름입니다.
  /// 성공 시 업데이트된 선수의 ID를 포함한 [Result<int>]를 반환합니다.
  /// 실패 시 적절한 오류를 포함한 [Result<int>]를 반환합니다.
  Future<Result<int>> execute({
    required int playerId, 
    required String name,
  }) async {
    // 이름의 좌우 공백 제거
    final trimmedName = name.trim();
    
    // 디버깅용 로그
    debugPrint('UpdatePlayerUseCase: 선수 정보 업데이트 요청 - ID: $playerId, 이름: $trimmedName');
    
    // 입력 유효성 검사
    if (trimmedName.isEmpty) {
      debugPrint('UpdatePlayerUseCase: 선수 이름이 비어있습니다.');
      return Result.failure(
        PlayerError(message: '선수 이름은 비어있을 수 없습니다.')
      );
    }
    
    try {
      // 기존 선수 정보 조회
      final playerResult = await _playerRepository.getPlayer(playerId);
      
      if (playerResult.isFailure) {
        debugPrint('UpdatePlayerUseCase: 선수 정보 조회 실패 - ${playerResult.error}');
        return Result.failure(playerResult.error);
      }
      
      final player = playerResult.value;
      
      if (player == null) {
        debugPrint('UpdatePlayerUseCase: 선수를 찾을 수 없음 - ID: $playerId');
        return Result.failure(
          PlayerError(message: '해당 ID의 선수를 찾을 수 없습니다.')
        );
      }
      
      // 선수 정보 업데이트 객체 생성
      final updatedPlayer = PlayersCompanion(
        id: Value(playerId),
        name: Value(trimmedName),
      );
      
      // 저장소를 통해 선수 정보 업데이트
      debugPrint('UpdatePlayerUseCase: 선수 정보 업데이트 중...');
      final result = await _playerRepository.updatePlayer(updatedPlayer);
      
      // 성공 시 결과 반환
      debugPrint('UpdatePlayerUseCase: 선수 정보 업데이트 성공 - ID: ${result.value}');
      return result;
    } catch (e) {
      // 오류 처리
      debugPrint('UpdatePlayerUseCase: 선수 정보 업데이트 실패 - 오류: $e');
      return Result.failure(
        PlayerError(
          message: '선수 정보 업데이트 중 오류가 발생했습니다.',
          cause: e,
        )
      );
    }
  }
} 