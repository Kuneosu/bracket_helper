import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/repository/match_repository.dart';
import 'package:bracket_helper/domain/repository/team_repository.dart';
import 'package:flutter/foundation.dart';

/// 매치 생성 파라미터 클래스
class CreateMatchParams {
  final int tournamentId;
  final int teamAId;
  final int teamBId;
  final int? order; // 경기 순서 (선택)
  final String? teamAName; // 팀명 (선택)
  final String? teamBName; // 팀명 (선택)

  CreateMatchParams({
    required this.tournamentId,
    required this.teamAId,
    required this.teamBId,
    this.order,
    this.teamAName,
    this.teamBName,
  });
}

/// 매치(경기) 생성 유스케이스
class CreateMatchUseCase {
  final MatchRepository _matchRepository;
  final TeamRepository _teamRepository;

  CreateMatchUseCase(this._matchRepository, this._teamRepository);

  /// 매치 생성 메서드
  ///
  /// [params] 매치 생성에 필요한 파라미터
  /// [params.tournamentId] 토너먼트 ID
  /// [params.teamAId] A팀 ID
  /// [params.teamBId] B팀 ID
  /// [params.order] 경기 순서 (선택)
  /// [params.teamAName] A팀 이름 (선택)
  /// [params.teamBName] B팀 이름 (선택)
  ///
  /// 성공 시 생성된 매치 정보를 포함한 [Result<Match>]를 반환합니다.
  /// 실패 시 에러 정보를 포함한 [Result<Match>]를 반환합니다.
  Future<Result<MatchModel>> execute(CreateMatchParams params) async {
    // 디버깅용 로그
    debugPrint(
      'CreateMatchUseCase: 매치 생성 요청 - '
      '토너먼트: ${params.tournamentId}, '
      '팀A: ${params.teamAId}, '
      '팀B: ${params.teamBId}',
    );

    // 팀 A 존재 여부 확인
    final teamAResult = await _teamRepository.getTeam(params.teamAId);
    if (teamAResult.isFailure) {
      debugPrint('CreateMatchUseCase: 팀A 조회 실패 - ${teamAResult.error}');
      return Result.failure(
        MatchError(message: '팀A를 찾을 수 없습니다.', cause: teamAResult.error),
      );
    }

    if (teamAResult.value == null) {
      debugPrint('CreateMatchUseCase: 팀A가 존재하지 않음 - ID: ${params.teamAId}');
      return Result.failure(
        MatchError(message: '팀A(ID: ${params.teamAId})가 존재하지 않습니다.'),
      );
    }

    // 팀 B 존재 여부 확인
    final teamBResult = await _teamRepository.getTeam(params.teamBId);
    if (teamBResult.isFailure) {
      debugPrint('CreateMatchUseCase: 팀B 조회 실패 - ${teamBResult.error}');
      return Result.failure(
        MatchError(message: '팀B를 찾을 수 없습니다.', cause: teamBResult.error),
      );
    }

    if (teamBResult.value == null) {
      debugPrint('CreateMatchUseCase: 팀B가 존재하지 않음 - ID: ${params.teamBId}');
      return Result.failure(
        MatchError(message: '팀B(ID: ${params.teamBId})가 존재하지 않습니다.'),
      );
    }

    // 동일한 팀으로 매치를 만들려는 경우 오류
    if (params.teamAId == params.teamBId) {
      debugPrint('CreateMatchUseCase: 동일한 팀으로 매치 생성 시도');
      return Result.failure(MatchError(message: '동일한 팀으로 매치를 구성할 수 없습니다.'));
    }

    // 선수 중복 확인 - 양쪽 팀에 같은 선수가 있는지 검사
    final teamA = teamAResult.value!;
    final teamB = teamBResult.value!;

    // 선수 ID 추출
    final teamAPlayerIds = <int>[teamA.player1Id];
    if (teamA.player2Id != null) {
      teamAPlayerIds.add(teamA.player2Id!);
    }

    final teamBPlayerIds = <int>[teamB.player1Id];
    if (teamB.player2Id != null) {
      teamBPlayerIds.add(teamB.player2Id!);
    }

    // 중복 선수 확인
    final duplicatePlayerIds =
        teamAPlayerIds.where((id) => teamBPlayerIds.contains(id)).toList();
    if (duplicatePlayerIds.isNotEmpty) {
      debugPrint('CreateMatchUseCase: 중복 선수 발견 - $duplicatePlayerIds');
      return Result.failure(
        MatchError(message: '한 매치에 동일한 선수가 양쪽 팀에 모두 포함될 수 없습니다.'),
      );
    }

    try {
      // 매치 생성 요청
      final teamAName = params.teamAName; // 파라미터에서 받은 팀명 사용
      final teamBName = params.teamBName; // 파라미터에서 받은 팀명 사용

      debugPrint('CreateMatchUseCase: 매치 저장소에 생성 요청 중...');
      final result = await _matchRepository.createMatch(
        tournamentId: params.tournamentId,
        teamAId: params.teamAId,
        teamBId: params.teamBId,
        teamAName: teamAName,
        teamBName: teamBName,
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
