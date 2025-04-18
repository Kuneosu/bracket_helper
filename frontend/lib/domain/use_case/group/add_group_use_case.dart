import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 그룹 추가 UseCase
class AddGroupUseCase {
  final GroupRepository _groupRepository;

  AddGroupUseCase(this._groupRepository);

  /// 그룹 추가
  ///
  /// [groupName] 추가할 그룹 이름
  /// [colorValue] 그룹 대표 색상 (int 형식의 Color 값)
  ///
  /// 반환값: 성공 시 [Result.success]와 함께 생성된 GroupModel,
  /// 실패 시 에러 정보를 포함한 [Result.failure]
  Future<Result<GroupModel>> execute({
    required String groupName,
    required int colorValue,
  }) async {
    if (kDebugMode) {
      print('AddGroupUseCase: 그룹 추가 시도 - 이름: $groupName, 색상: ${Color(colorValue)}');
    }
    
    if (groupName.trim().isEmpty) {
      return Result.failure(
        GroupError(message: '그룹 이름은 비어있을 수 없습니다.'),
      );
    }

    try {
      // 그룹 추가 요청 (색상 포함)
      final result = await _groupRepository.addGroup(
        GroupsCompanion.insert(
          name: groupName,
          color: Value(colorValue),
        ),
      );
      
      if (result.isSuccess) {
        final groupId = result.value;
        if (kDebugMode) {
          print('AddGroupUseCase: 그룹 추가 성공 - ID: $groupId');
        }
        
        // 그룹 모델 생성하여 반환 (색상 포함)
        final groupModel = GroupModel(
          id: groupId,
          name: groupName,
          color: Color(colorValue),
        );
        
        return Result.success(groupModel);
      } else {
        if (kDebugMode) {
          print('AddGroupUseCase: 그룹 추가 실패 - ${result.error.message}');
        }
        
        return Result.failure(result.error);
      }
    } catch (e) {
      // 예상치 못한 예외 처리
      if (kDebugMode) {
        print('AddGroupUseCase: 예상치 못한 예외 발생 - $e');
      }
      
      return Result.failure(
        GroupError(
          message: '그룹 추가 중 오류가 발생했습니다.',
          cause: e,
        ),
      );
    }
  }
} 