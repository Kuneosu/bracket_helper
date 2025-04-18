import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 모든 그룹 목록을 조회하는 UseCase
class GetAllGroupsUseCase {
  final GroupRepository _groupRepository;

  GetAllGroupsUseCase(this._groupRepository);

  /// 모든 그룹 목록 조회 실행
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 그룹 목록,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<List<GroupModel>>> execute() async {
    try {
      // 디버그 로그
      if (kDebugMode) {
        print('GetAllGroupsUseCase: 모든 그룹 목록 조회 시도');
      }

      // 레포지토리 호출
      final result = await _groupRepository.fetchAllGroups();

      // 데이터베이스 모델을 도메인 모델로 변환
      if (result.isSuccess) {
        final groups = result.value;
        final groupModels = groups.map((group) => GroupModel(
          id: group.id,
          name: group.name,
          color: group.color != null ? Color(group.color!) : null,
        )).toList();
        
        // 디버그 로그
        if (kDebugMode) {
          print('GetAllGroupsUseCase: 그룹 목록 ${groupModels.length}개 변환 완료');
        }
        
        return Result.success(groupModels);
      }

      // 디버그 로그
      if (kDebugMode) {
        print('GetAllGroupsUseCase: 그룹 목록 조회 실패 - ${result.error}');
      }

      return Result.failure(result.error);
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