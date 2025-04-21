import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match_model.dart' as domain;
import 'package:bracket_helper/domain/model/tournament_model.dart';

abstract class TournamentRepository {
  /// 모든 토너먼트 가져오기
  Future<Result<List<TournamentModel>>> fetchAllTournaments();

  /// 토너먼트 추가하기
  Future<Result<int>> addTournament(TournamentsCompanion tournament);

  /// 토너먼트와 매치 함께 추가하기
  Future<Result<int>> addTournamentWithMatches(
    TournamentsCompanion tournament,
    List<domain.MatchModel> matches,
  );

  /// 토너먼트 정보 가져오기
  Future<Result<TournamentModel?>> getTournament(int id);

  /// 토너먼트 삭제하기
  Future<Result<void>> deleteTournament(int id);

  /// 토너먼트 정보 업데이트하기
  Future<Result<void>> updateTournament(TournamentsCompanion tournament);

  /// 토너먼트 내 매치 가져오기
  Future<Result<List<domain.MatchModel>>> fetchMatchesByTournament(int tournamentId);
}
