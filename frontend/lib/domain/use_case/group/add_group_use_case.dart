import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:flutter/foundation.dart';

/// 그룹 추가 UseCase
class AddGroupUseCase {
  final GroupRepository _groupRepository;

  AddGroupUseCase(this._groupRepository);

  /// 그룹 추가
  ///
  /// 성공 시 그룹 ID를 반환하고, 실패 시 에러 메시지를 반환합니다.
  Future<dynamic> execute(String groupName) async {
    if (kDebugMode) {
      print('UseCase: 그룹 추가 시도 - 이름: $groupName');
    }
    
    if (groupName.trim().isEmpty) {
      return '그룹 이름은 비어있을 수 없습니다.';
    }

    try {
      final Result<int> result = await _groupRepository.addGroup(
        GroupsCompanion.insert(name: groupName),
      );
      
      if (result.isSuccess) {
        if (kDebugMode) {
          print('UseCase: 그룹 추가 성공 - ID: ${result.value}');
        }
        return result.value; // 성공 시 그룹 ID 반환
      } else {
        final error = result.error;
        String errorMessage;
        
        if (error is DatabaseError) {
          errorMessage = '그룹 추가 실패: ${error.message}';
        } else {
          errorMessage = '그룹 추가 실패: ${error.message}';
        }
        
        if (kDebugMode) {
          print('UseCase: 오류 발생 - $errorMessage');
        }
        
        return errorMessage;
      }
    } catch (e) {
      // 예상치 못한 예외 처리
      if (kDebugMode) {
        print('UseCase: 예상치 못한 예외 발생 - $e');
      }
      return '그룹 추가 중 오류 발생: $e';
    }
  }
} 