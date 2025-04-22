import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/repository/match_repository.dart';
import 'package:flutter/foundation.dart';

/// 매치(경기) 생성 유스케이스
class CreateMatchUseCase {
  final MatchRepository _matchRepository;

  CreateMatchUseCase(this._matchRepository);

  /// 매치 생성 메서드
  ///
  /// [params] 매치 생성에 필요한 파라미터
  /// [params.tournamentId] 토너먼트 ID
  /// [params.playerA] A팀 선수1
  /// [params.playerB] B팀 선수1
  /// [params.playerC] A팀 선수2 (복식인 경우)
  /// [params.playerD] B팀 선수2 (복식인 경우)
  /// [params.order] 경기 순서 (선택)
  ///
  /// 성공 시 생성된 매치 정보를 포함한 [Result<Match>]를 반환합니다.
  /// 실패 시 에러 정보를 포함한 [Result<Match>]를 반환합니다.
  Future<Result<MatchModel>> execute(MatchModel params) async {
    // 디버깅용 로그
    debugPrint(
      'CreateMatchUseCase: 매치 생성 요청 - '
      '토너먼트: ${params.tournamentId}, '
      '선수A: ${params.playerA}, '
      '선수B: ${params.playerB}, '
      '선수C: ${params.playerC}, '
      '선수D: ${params.playerD}',
    );

    // 필수 필드 검증
    if (params.playerA == null || params.playerB == null) {
      debugPrint('CreateMatchUseCase: 필수 선수 정보 부족');
      return Result.failure(MatchError(message: '매치 생성에 필요한 선수 정보가 부족합니다.'));
    }

    // 동일한 선수를 양쪽에 배치하려는 경우 오류
    if (params.playerA == params.playerB ||
        (params.playerC != null && params.playerC == params.playerD) ||
        (params.playerC != null && params.playerC == params.playerB) ||
        (params.playerD != null && params.playerD == params.playerA)) {
      debugPrint('CreateMatchUseCase: 동일한 선수로 매치 생성 시도');
      return Result.failure(MatchError(message: '동일한 선수로 매치를 구성할 수 없습니다.'));
    }

    try {
      // 매치 생성 요청
      debugPrint('CreateMatchUseCase: 매치 저장소에 생성 요청 중...');

      final result = await _matchRepository.createMatch(
        tournamentId: params.tournamentId!,
        playerA: params.playerA!,
        playerB: params.playerB!,
        playerC: params.playerC,
        playerD: params.playerD,
      );

      // 성공 시 결과 반환
      debugPrint('CreateMatchUseCase: 매치 생성 성공 - ID: ${result.value.id}');
      return result;
    } catch (e) {
      // 오류 처리
      debugPrint('CreateMatchUseCase: 매치 생성 실패 - 오류: $e');
      return Result.failure(
        MatchError(message: '매치 생성 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}

/// 매치 관련 오류
class MatchError extends AppError {
  MatchError({required super.message, super.cause});
}
