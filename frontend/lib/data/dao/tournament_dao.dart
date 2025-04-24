import 'package:drift/drift.dart';
import '../database/tables.dart';
import '../database/app_database.dart';

part 'tournament_dao.g.dart';

@DriftAccessor(tables: [Tournaments, Matches, Teams])
class TournamentDao extends DatabaseAccessor<AppDatabase>
    with _$TournamentDaoMixin {
  TournamentDao(super.db);

  /* 토너먼트 + 매치 일괄 저장 */
  Future<int> insertTournamentWithMatches(
    TournamentsCompanion tournament,
    List<MatchesCompanion> matchesComp,
  ) async {
    return transaction(() async {
      final id = await into(tournaments).insert(tournament);
      await batch(
        (b) => b.insertAll(
          matches,
          matchesComp.map((m) => m.copyWith(tournamentId: Value(id))).toList(),
        ),
      );
      return id;
    });
  }

  /* 토너먼트 + 매치 조회 */
  Future<TournamentWithMatches?> fetchTournament(int id) async {
    final t =
        await (select(tournaments)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (t == null) return null;

    // 쿼리를 실행할 코드를 생성합니다 (직접 SQL 사용)
    final query = customSelect(
      'SELECT * FROM matches WHERE tournament_id = ? ORDER BY ord ASC;',
      variables: [Variable.withInt(id)],
    );
    
    // 결과를 Matche 객체로 변환합니다
    final rows = await query.get();
    final matchList = rows.map((row) {
      return Matche(
        id: row.read<int>('id'),
        tournamentId: row.read<int>('tournament_id'),
        ord: row.read<int>('ord'),
        playerA: row.readNullable<String>('player_a'),
        playerB: row.readNullable<String>('player_b'),
        playerC: row.readNullable<String>('player_c'),
        playerD: row.readNullable<String>('player_d'),
        scoreA: row.readNullable<int>('score_a'),
        scoreB: row.readNullable<int>('score_b'),
      );
    }).toList();

    return TournamentWithMatches(t, matchList);
  }
  
  /* 모든 토너먼트 조회 */
  Future<List<Tournament>> fetchAllTournaments() {
    return select(tournaments).get();
  }
  
  /* 토너먼트 삭제 */
  Future<void> deleteTournament(int tournamentId) {
    return transaction(() async {
      // 1. 토너먼트의 매치 삭제
      await (delete(matches)..where((tbl) => tbl.tournamentId.equals(tournamentId))).go();
      // 2. 토너먼트 삭제
      await (delete(tournaments)..where((tbl) => tbl.id.equals(tournamentId))).go();
    });
  }
}

/* DTO */
class TournamentWithMatches {
  final Tournament tournament;
  final List<Matche> matches;
  TournamentWithMatches(this.tournament, this.matches);
}
