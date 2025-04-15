import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match.dart' as domain;

abstract class TournamentRepository {
  /// 모든 토너먼트 가져오기
  Future<Result<List<Tournament>>> fetchAllTournaments();
  
  /// 토너먼트 추가하기
  Future<Result<int>> addTournament(TournamentsCompanion tournament);
  
  /// 토너먼트와 매치 함께 추가하기
  Future<Result<int>> addTournamentWithMatches(TournamentsCompanion tournament, List<domain.Match> matches);
  
  /// 토너먼트 정보 가져오기
  Future<Result<Tournament?>> getTournament(int id);
  
  /// 토너먼트 삭제하기
  Future<Result<void>> deleteTournament(int id);
  
  /// 토너먼트 정보 업데이트하기
  Future<Result<void>> updateTournament(TournamentsCompanion tournament);
  
  /// 토너먼트 내 매치 가져오기
  Future<Result<List<domain.Match>>> fetchMatchesByTournament(int tournamentId);
} 