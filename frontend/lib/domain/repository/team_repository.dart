import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/result.dart';

/// 팀 관련 Repository 인터페이스
abstract class TeamRepository {
  /// 모든 팀 조회
  Future<Result<List<Team>>> fetchAllTeams();
  
  /// 선수 정보가 포함된 팀 목록 조회
  Future<Result<List<dynamic>>> fetchTeamsWithPlayers();
  
  /// 팀 추가
  Future<Result<int>> createTeam(TeamsCompanion team);
  
  /// 팀 정보 조회
  Future<Result<Team?>> getTeam(int teamId);
  
  /// 팀 삭제
  Future<Result<void>> deleteTeam(int teamId);
} 