import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 그룹 정보 업데이트 UseCase
class UpdateGroupUseCase {
  final GroupRepository _groupRepository;

  UpdateGroupUseCase(this._groupRepository);

  /// 그룹 정보 업데이트 실행
  ///
  /// [groupId] 업데이트할 그룹의 ID
  /// [newName] 새로운 그룹 이름 (null인 경우 업데이트하지 않음)
  /// [newColor] 새로운 그룹 색상 (null인 경우 업데이트하지 않음)
  ///
  /// 반환값: 성공 시 업데이트 성공 여부를 포함한 [Result.success],
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<bool>> execute({
    required int groupId,
    String? newName,
    Color? newColor,
  }) async {
    try {
      // 유효성 검증
      if (groupId <= 0) {
        return Result.failure(
          GroupError(message: '유효하지 않은 그룹 ID입니다.'),
        );
      }

      // newName과 newColor가 모두 null인 경우
      if (newName == null && newColor == null) {
        return Result.failure(
          GroupError(message: '업데이트할 정보가 없습니다.'),
        );
      }

      // 이름이 제공된 경우 이름 유효성 검사
      if (newName != null && newName.trim().isEmpty) {
        return Result.failure(
          GroupError(message: '그룹 이름은 비워둘 수 없습니다.'),
        );
      }

      // 디버그 로그
      if (kDebugMode) {
        print('UpdateGroupUseCase: 그룹 업데이트 시도 - ID: $groupId, 이름: "$newName", 색상: $newColor');
      }

      // 색상 값 변환
      final colorValue = newColor?.toARGB32();

      // 그룹 업데이트 요청
      final result = await _groupRepository.updateGroup(
        groupId, 
        newName?.trim() ?? '', 
        colorValue
      );

      // 디버그 로그
      if (kDebugMode) {
        print('UpdateGroupUseCase: 그룹 레포지토리 응답 - $result');
      }

      // 결과 전달
      return result;
    } catch (e) {
      // 디버그 로그
      if (kDebugMode) {
        print('UpdateGroupUseCase: 예외 발생 - $e');
      }

      return Result.failure(
        GroupError(
          message: '그룹을 업데이트하는 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 