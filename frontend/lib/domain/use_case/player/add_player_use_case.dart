import 'package:bracket_helper/domain/repository/player_repository.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// 선수 추가를 위한 유스케이스
class AddPlayerUseCase {
  final PlayerRepository _playerRepository;

  AddPlayerUseCase(this._playerRepository);

  /// 선수 이름을 받아 선수를 추가하는 함수
  ///
  /// 입력된 이름이 유효한지 검증한 후, 선수를 데이터베이스에 추가합니다.
  /// [name]은 선수의 이름입니다.
  /// 성공 시 추가된 선수의 ID를 포함한 [Result<int>]를 반환합니다.
  /// 실패 시 적절한 오류를 포함한 [Result<int>]를 반환합니다.
  Future<Result<int>> execute(String name) async {
    // 이름의 좌우 공백 제거
    final trimmedName = name.trim();
    
    // 디버깅용 로그
    debugPrint('AddPlayerUseCase: 선수 추가 요청 - 이름: $trimmedName (원본: $name)');
    
    // 입력 유효성 검사
    if (trimmedName.isEmpty) {
      debugPrint('AddPlayerUseCase: 선수 이름이 비어있습니다.');
      return Result.failure(
        PlayerError(message: '선수 이름은 비어있을 수 없습니다.')
      );
    }
    
    try {
      // 선수 객체 생성 (좌우 공백이 제거된 이름 사용)
      final player = PlayersCompanion(
        name: Value(trimmedName),
      );
      
      // 저장소를 통해 선수 추가
      debugPrint('AddPlayerUseCase: 선수 저장소에 추가 중...');
      final result = await _playerRepository.addPlayer(player);
      
      // 성공 시 결과 반환
      debugPrint('AddPlayerUseCase: 선수 추가 성공 - ID: ${result.value}');
      return result;
    } catch (e) {
      // 오류 처리
      debugPrint('AddPlayerUseCase: 선수 추가 실패 - 오류: $e');
      return Result.failure(
        PlayerError(
          message: '선수 추가 중 오류가 발생했습니다.',
          cause: e,
        )
      );
    }
  }
} 