import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/result.dart';

/// 선수 관련 Repository 인터페이스
abstract class PlayerRepository {
  /// 모든 선수 조회
  Future<Result<List<Player>>> fetchAllPlayers();
  
  /// 선수 추가
  Future<Result<int>> addPlayer(PlayersCompanion player);
  
  /// 선수 정보 조회
  Future<Result<Player?>> getPlayer(int playerId);
  
  /// 선수 삭제
  Future<Result<void>> deletePlayer(int playerId);
  
  /// 선수 정보 업데이트
  Future<Result<int>> updatePlayer(PlayersCompanion player);
} 