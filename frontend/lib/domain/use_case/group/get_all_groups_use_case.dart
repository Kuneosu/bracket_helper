import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:flutter/foundation.dart';

/// 모든 그룹 목록을 조회하는 UseCase
class GetAllGroupsUseCase {
  final GroupRepository _groupRepository;

  GetAllGroupsUseCase(this._groupRepository);

  /// 모든 그룹 목록 조회 실행
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 그룹 목록,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<List<Group>>> execute() async {
    try {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllGroupsUseCase: 모든 그룹 목록 조회 시도');
      }

      // 레포지토리 호출
      final result = await _groupRepository.fetchAllGroups();

      // 디버그 로그
      if (kDebugMode) {
        if (result.isSuccess) {
          print('GetAllGroupsUseCase: 그룹 목록 ${result.value.length}개 조회 성공');
        } else {
          print('GetAllGroupsUseCase: 그룹 목록 조회 실패 - ${result.error}');
        }
      }

      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllGroupsUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        GroupError(
          message: '그룹 목록을 조회하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 