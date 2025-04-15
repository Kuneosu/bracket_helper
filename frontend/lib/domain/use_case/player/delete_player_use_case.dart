import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/player_repository.dart';
import 'package:flutter/foundation.dart';

/// 선수 삭제 UseCase
class DeletePlayerUseCase {
  final PlayerRepository _playerRepository;

  DeletePlayerUseCase(this._playerRepository);

  /// 선수 삭제 실행
  /// 
  /// [playerId]는 삭제할 선수의 ID입니다.
  /// 
  /// 반환값: 성공 시 [Result.success],
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<Unit>> execute(int playerId) async {
    try {
      // 유효성 검증
      if (playerId <= 0) {
        return Result.failure(
          PlayerError(message: '유효하지 않은 선수 ID입니다.'),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print('DeletePlayerUseCase: 선수 삭제 시도 - ID: $playerId');
      }

      // 선수 삭제 요청
      final result = await _playerRepository.deletePlayer(playerId);

      // 디버그 로그
      if (kDebugMode) {
        print('DeletePlayerUseCase: 선수 레포지토리 응답 - $result');
      }

      // result가 이미 Result<void> 타입이므로 Unit으로 변환하여 반환
      if (result.isSuccess) {
        return Result.successVoid;
      } else {
        return Result.failure(result.error);
      }
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('DeletePlayerUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        PlayerError(
          message: '선수를 삭제하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 