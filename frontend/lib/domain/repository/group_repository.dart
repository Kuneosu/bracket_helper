import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/result.dart';

/// 그룹 관련 Repository 인터페이스
abstract class GroupRepository {
  /// 모든 그룹 조회
  Future<Result<List<Group>>> fetchAllGroups();
  
  /// 그룹 추가
  Future<Result<int>> addGroup(GroupsCompanion group);
  
  /// 그룹에 선수 추가
  Future<Result<void>> addPlayerToGroup(int playerId, int groupId);
  
  /// 그룹에 속한 선수 목록 조회
  Future<Result<List<Player>>> fetchPlayersInGroup(int groupId);
  
  /// 그룹에 속한 선수 수 조회
  Future<Result<int>> countPlayersInGroup(int groupId);
  
  /// 그룹 삭제
  Future<Result<int>> deleteGroup(int groupId);
  
  /// 그룹에서 선수 제거
  Future<Result<int>> removePlayerFromGroup(int playerId, int groupId);
  
  /// 그룹 정보 업데이트
  Future<Result<bool>> updateGroup(int groupId, String newName, int? newColor);
} 