import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/player_repository.dart';
import 'package:bracket_helper/domain/repository/team_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// 팀 생성 파라미터 클래스
class CreateTeamParams {
  final int player1Id;
  final int? player2Id; // 단식팀은 null

  CreateTeamParams({
    required this.player1Id,
    this.player2Id,
  });
}

/// 팀 생성 UseCase
class CreateTeamUseCase {
  final TeamRepository _teamRepository;
  final PlayerRepository _playerRepository;

  CreateTeamUseCase(this._teamRepository, this._playerRepository);

  /// 팀 생성 메서드
  ///
  /// [params] 팀 생성에 필요한 파라미터
  /// [params.player1Id] 첫 번째 선수 ID (필수)
  /// [params.player2Id] 두 번째 선수 ID (선택, 단식팀은 null)
  ///
  /// 성공 시 생성된 팀 ID를 포함한 [Result<int>]를 반환합니다.
  /// 실패 시 에러 정보를 포함한 [Result<int>]를 반환합니다.
  Future<Result<int>> execute(CreateTeamParams params) async {
    // 디버깅용 로그
    debugPrint('CreateTeamUseCase: 팀 생성 요청 - 선수1: ${params.player1Id}, 선수2: ${params.player2Id}');
    
    // 선수1 존재 여부 확인
    final player1Result = await _playerRepository.getPlayer(params.player1Id);
    if (player1Result.isFailure) {
      debugPrint('CreateTeamUseCase: 선수1 조회 실패 - ${player1Result.error}');
      return Result.failure(
        TeamError(message: '선수1을 찾을 수 없습니다.', cause: player1Result.error)
      );
    }
    
    if (player1Result.value == null) {
      debugPrint('CreateTeamUseCase: 선수1이 존재하지 않음 - ID: ${params.player1Id}');
      return Result.failure(
        TeamError(message: '선수1(ID: ${params.player1Id})이 존재하지 않습니다.')
      );
    }
    
    // 선수2가 지정된 경우, 존재 여부 확인
    if (params.player2Id != null) {
      final player2Result = await _playerRepository.getPlayer(params.player2Id!);
      if (player2Result.isFailure) {
        debugPrint('CreateTeamUseCase: 선수2 조회 실패 - ${player2Result.error}');
        return Result.failure(
          TeamError(message: '선수2를 찾을 수 없습니다.', cause: player2Result.error)
        );
      }
      
      if (player2Result.value == null) {
        debugPrint('CreateTeamUseCase: 선수2가 존재하지 않음 - ID: ${params.player2Id}');
        return Result.failure(
          TeamError(message: '선수2(ID: ${params.player2Id})가 존재하지 않습니다.')
        );
      }
      
      // 동일한 선수로 팀을 만들려는 경우 오류
      if (params.player1Id == params.player2Id) {
        debugPrint('CreateTeamUseCase: 동일한 선수로 팀 생성 시도');
        return Result.failure(
          TeamError(message: '동일한 선수로 팀을 구성할 수 없습니다.')
        );
      }
    }
    
    try {
      // 팀 객체 생성
      final team = TeamsCompanion.insert(
        player1Id: params.player1Id,
        player2Id: params.player2Id != null ? Value(params.player2Id) : const Value.absent(),
      );
      
      // 저장소를 통해 팀 생성
      debugPrint('CreateTeamUseCase: 팀 저장소에 생성 요청 중...');
      final result = await _teamRepository.createTeam(team);
      
      // 성공 시 결과 반환
      debugPrint('CreateTeamUseCase: 팀 생성 성공 - ID: ${result.value}');
      return result;
    } catch (e) {
      // 오류 처리
      debugPrint('CreateTeamUseCase: 팀 생성 실패 - 오류: $e');
      return Result.failure(
        TeamError(
          message: '팀 생성 중 오류가 발생했습니다.',
          cause: e,
        )
      );
    }
  }
} 