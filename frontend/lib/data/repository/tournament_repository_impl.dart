import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/match_dao.dart';
import 'package:bracket_helper/data/dao/tournament_dao.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/model/match_model.dart' as domain;
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/repository/tournament_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert'; // JSON 처리를 위해 추가

class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentDao _tournamentDao;
  final MatchDao _matchDao;
  final AppDatabase _database;

  TournamentRepositoryImpl(this._tournamentDao, this._matchDao, this._database);

  // 데이터베이스 Tournament 모델을 도메인 Tournament 모델로 변환
  TournamentModel _mapToDomainTournament(Tournament dbTournament) {
    // JSON 문자열에서 파트너 쌍 리스트로 변환
    List<List<String>> partnerPairs = [];
    try {
      if (dbTournament.partnerPairs.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(dbTournament.partnerPairs);
        partnerPairs = jsonList
            .map((item) => (item as List<dynamic>)
                .map((e) => e.toString())
                .toList())
            .toList();
      }
    } catch (e) {
      debugPrint('파트너 쌍 JSON 파싱 오류: $e');
      // 오류 발생 시 빈 리스트 사용
      partnerPairs = [];
    }

    return TournamentModel(
      id: dbTournament.id,
      title: dbTournament.title,
      date: dbTournament.date,
      winPoint: dbTournament.winPoint,
      drawPoint: dbTournament.drawPoint,
      losePoint: dbTournament.losePoint,
      gamesPerPlayer: dbTournament.gamesPerPlayer,
      isDoubles: dbTournament.isDoubles,
      process: dbTournament.process,
      isPartnerMatching: dbTournament.isPartnerMatching,
      partnerPairs: partnerPairs,
    );
  }

  @override
  Future<Result<List<TournamentModel>>> fetchAllTournaments() async {
    try {
      final tournaments = await _tournamentDao.fetchAllTournaments();
      // 데이터베이스 모델을 도메인 모델로 변환
      final domainTournaments =
          tournaments.map(_mapToDomainTournament).toList();
      return Result.success(domainTournaments);
    } catch (e) {
      debugPrint('TournamentRepositoryImpl: 토너먼트 목록 조회 실패 - $e');
      return Result.failure(
        DatabaseError(message: '토너먼트 목록을 불러오는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<int>> addTournament(TournamentsCompanion tournament) async {
    try {
      final id = await _tournamentDao.insertTournamentWithMatches(
        tournament,
        [],
      );
      return Result.success(id);
    } catch (e) {
      debugPrint('TournamentRepositoryImpl: 토너먼트 추가 실패 - $e');
      return Result.failure(
        DatabaseError(message: '토너먼트를 추가하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<int>> addTournamentWithMatches(
    TournamentsCompanion tournament,
    List<domain.MatchModel> matches,
  ) async {
    try {
      final matchesCompanions =
          matches.map((match) {
            return MatchesCompanion(
              tournamentId: Value(0),
              playerA:
                  match.playerA != null
                      ? Value(match.playerA!)
                      : const Value.absent(),
              playerB:
                  match.playerB != null
                      ? Value(match.playerB!)
                      : const Value.absent(),
              playerC:
                  match.playerC != null
                      ? Value(match.playerC!)
                      : const Value.absent(),
              playerD:
                  match.playerD != null
                      ? Value(match.playerD!)
                      : const Value.absent(),
              ord: match.ord != null ? Value(match.ord!) : const Value(0),
              scoreA:
                  match.scoreA != null
                      ? Value(match.scoreA!)
                      : const Value.absent(),
              scoreB:
                  match.scoreB != null
                      ? Value(match.scoreB!)
                      : const Value.absent(),
            );
          }).toList();

      final id = await _tournamentDao.insertTournamentWithMatches(
        tournament,
        matchesCompanions,
      );
      return Result.success(id);
    } catch (e) {
      debugPrint('TournamentRepositoryImpl: 토너먼트와 매치 추가 실패 - $e');
      return Result.failure(
        DatabaseError(message: '토너먼트와 매치를 추가하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<TournamentModel>> fetchTournamentById(int id) async {
    try {
      final tournamentWithMatches = await _tournamentDao.fetchTournament(id);
      if (tournamentWithMatches?.tournament != null) {
        // 데이터베이스 모델을 도메인 모델로 변환
        return Result.success(
          _mapToDomainTournament(tournamentWithMatches!.tournament),
        );
      }
      return Result.success(
        TournamentModel(id: 0, title: '', date: DateTime.now()),
      );
    } catch (e) {
      debugPrint('TournamentRepositoryImpl: 토너먼트 정보 조회 실패 - $e');
      return Result.failure(
        DatabaseError(message: '토너먼트 정보를 불러오는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Unit>> deleteTournament(int id) async {
    try {
      await _tournamentDao.deleteTournament(id);
      return Result.successVoid;
    } catch (e) {
      debugPrint('TournamentRepositoryImpl: 토너먼트 삭제 실패 - $e');
      return Result.failure(
        DatabaseError(message: '토너먼트를 삭제하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<Unit>> updateTournament(TournamentsCompanion tournament) async {
    try {
      await (_database.update(_database.tournaments)
        ..where((tbl) => tbl.id.equals(tournament.id.value))).write(tournament);
      return Result.successVoid;
    } catch (e) {
      debugPrint('TournamentRepositoryImpl: 토너먼트 업데이트 실패 - $e');
      return Result.failure(
        DatabaseError(message: '토너먼트 정보를 업데이트하는데 실패했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<domain.MatchModel>>> fetchMatchesByTournament(
    int tournamentId,
  ) async {
    try {
      final matches = await _matchDao.fetchMatchesByTournament(tournamentId);
      return Result.success(matches);
    } catch (e) {
      debugPrint('TournamentRepositoryImpl: 토너먼트 내 매치 조회 실패 - $e');
      return Result.failure(
        DatabaseError(message: '토너먼트 내 매치를 불러오는데 실패했습니다.', cause: e),
      );
    }
  }
}
