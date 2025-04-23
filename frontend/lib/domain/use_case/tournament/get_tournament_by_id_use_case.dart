import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/repository/tournament_repository.dart';
import 'package:flutter/foundation.dart';

/// 모든 토너먼트 목록을 조회하는 UseCase
class GetTournamentByIdUseCase {
  final TournamentRepository _tournamentRepository;

  GetTournamentByIdUseCase(this._tournamentRepository);

  /// 토너먼트 조회 실행
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 토너먼트 목록,s
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<TournamentModel>> execute(int id) async {
    try {
      // 디버그 로그
      if (kDebugMode) {
        print('GetTournamentByIdUseCase: 토너먼트 조회 시도');
      }

      // 레포지토리 호출
      final result = await _tournamentRepository.fetchTournamentById(id);

      // 디버그 로그
      if (kDebugMode) {
        if (result.isSuccess) {
          print(
            'GetTournamentByIdUseCase: 토너먼트 조회 성공',
          );
        } else {
          print('GetTournamentByIdUseCase: 토너먼트 조회 실패 - ${result.error}');
        }
      }

      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('GetTournamentByIdUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        TournamentError(message: '토너먼트 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
