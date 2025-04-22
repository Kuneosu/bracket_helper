import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/repository/tournament_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// 토너먼트 생성 UseCase의 입력 파라미터
class CreateTournamentParams {
  final String title;
  final DateTime date;
  final int winPoint;
  final int drawPoint;
  final int losePoint;
  final int gamesPerPlayer;
  final bool isDoubles;
  final int process;

  const CreateTournamentParams({
    required this.title,
    required this.date,
    this.winPoint = 1,
    this.drawPoint = 0,
    this.losePoint = 0,
    this.gamesPerPlayer = 4,
    this.isDoubles = true,
    this.process = 0,
  });

  factory CreateTournamentParams.fromTournamentModel(TournamentModel model) {
    return CreateTournamentParams(
      title: model.title,
      date: model.date,
      winPoint: model.winPoint,
      drawPoint: model.drawPoint,
      losePoint: model.losePoint,
      gamesPerPlayer: model.gamesPerPlayer,
      isDoubles: model.isDoubles,
      process: model.process,
    );
  }

  @override
  String toString() =>
      'CreateTournamentParams(title: $title, date: $date, '
      'winPoint: $winPoint, drawPoint: $drawPoint, losePoint: $losePoint, '
      'gamesPerPlayer: $gamesPerPlayer, isDoubles: $isDoubles, process: $process)';
}

/// 토너먼트 생성 UseCase
class CreateTournamentUseCase {
  final TournamentRepository _tournamentRepository;

  CreateTournamentUseCase(this._tournamentRepository);

  /// 토너먼트 생성 실행
  ///
  /// [params]에는 토너먼트 제목과 날짜가 포함되어야 합니다.
  ///
  /// 반환값: 성공 시 Tournament의 ID를 포함한 [Result.success],
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<int>> execute(CreateTournamentParams params) async {
    try {
      // 유효성 검증
      if (params.title.trim().isEmpty) {
        return Result.failure(TournamentError(message: '토너먼트 제목은 필수입니다.'));
      }

      // 토너먼트 생성 데이터 준비
      final tournamentData = TournamentsCompanion.insert(
        title: params.title.trim(),
        date: params.date,
        winPoint: Value(params.winPoint),
        drawPoint: Value(params.drawPoint),
        losePoint: Value(params.losePoint),
        gamesPerPlayer: Value(params.gamesPerPlayer),
        isDoubles: Value(params.isDoubles),
        process: Value(params.process),
      );

      // 디버그 로그
      debugPrint('CreateTournamentUseCase: 토너먼트 생성 시도 - ${params.title}');

      // 토너먼트 저장
      final tournamentId = await _tournamentRepository.addTournament(
        tournamentData,
      );

      // 디버그 로그
      debugPrint('CreateTournamentUseCase: 토너먼트 생성 성공 - ID: $tournamentId');

      // tournamentId가 Result<int> 타입이면 그대로 반환, int 타입이면 Result로 래핑
      return tournamentId;
    } catch (e) {
      // 디버그 로그
      debugPrint('CreateTournamentUseCase: 토너먼트 생성 실패 - $e');

      return Result.failure(
        TournamentError(message: '토너먼트를 생성하는 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
