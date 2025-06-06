import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/repository/tournament_repository.dart';
import 'package:flutter/foundation.dart';

/// 모든 토너먼트 목록을 조회하는 UseCase
class GetAllTournamentsUseCase {
  final TournamentRepository _tournamentRepository;

  GetAllTournamentsUseCase(this._tournamentRepository);

  /// 모든 토너먼트 목록 조회 실행
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 토너먼트 목록,s
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<List<TournamentModel>>> execute() async {
    try {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllTournamentsUseCase: 모든 토너먼트 목록 조회 시도');
      }

      // 레포지토리 호출
      final result = await _tournamentRepository.fetchAllTournaments();

      // 디버그 로그
      if (kDebugMode) {
        if (result.isSuccess) {
          print(
            'GetAllTournamentsUseCase: 토너먼트 목록 ${result.value.length}개 조회 성공',
          );
        } else {
          print('GetAllTournamentsUseCase: 토너먼트 목록 조회 실패 - ${result.error}');
        }
      }

      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllTournamentsUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        TournamentError(message: '토너먼트 목록을 조회하는 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
