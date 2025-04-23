import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match_model.dart' as domain;
import 'package:bracket_helper/domain/repository/match_repository.dart';
import 'package:flutter/foundation.dart';

/// 모든 매치 조회 UseCase
class GetAllMatchesUseCase {
  final MatchRepository _matchRepository;

  GetAllMatchesUseCase(this._matchRepository);

  /// 데이터베이스에 저장된 모든 매치 조회 실행
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 매치 목록,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<List<domain.MatchModel>>> execute() async {
    try {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllMatchesUseCase: 모든 매치 조회 시도');
      }

      // 매치 조회 요청
      final result = await _matchRepository.fetchAllMatches();

      // 디버그 로그
      if (kDebugMode) {
        if (result.isSuccess) {
          print('GetAllMatchesUseCase: 총 ${result.value.length}개 매치 조회 성공');
        } else {
          print('GetAllMatchesUseCase: 매치 조회 실패 - ${result.error}');
        }
      }

      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllMatchesUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        DatabaseError(
          message: '모든 매치를 조회하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 