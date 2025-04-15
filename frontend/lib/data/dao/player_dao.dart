import 'package:drift/drift.dart';
import '../database/tables.dart';
import '../database/app_database.dart';

part 'player_dao.g.dart';

@DriftAccessor(tables: [Players, PlayerGroups, Teams])
class PlayerDao extends DatabaseAccessor<AppDatabase> with _$PlayerDaoMixin {
  PlayerDao(super.db);

  /* 선수 저장 (있으면 업데이트) */
  Future<int> upsertPlayer(PlayersCompanion p) =>
      into(players).insert(
        p,
        onConflict: DoUpdate(
          (old) => p,
          target: [players.id],
        ),
      );

  /* 특정 그룹의 선수 목록 */
  Future<List<Player>> fetchPlayersByGroup(int groupId) {
    return (select(players)..where(
      (p) => existsQuery(
        select(playerGroups)..where(
          (pg) => pg.playerId.equalsExp(p.id) & pg.groupId.equals(groupId),
        ),
      ),
    )).get();
  }

  /* 모든 선수 */
  Future<List<Player>> fetchAllPlayers() => select(players).get();

  /* 선수 한 명 조회 */
  Future<Player?> getPlayer(int id) =>
      (select(players)..where((p) => p.id.equals(id))).getSingleOrNull();

  /* 선수 삭제 */
  Future<void> deletePlayer(int playerId) {
    return transaction(() async {
      // 1. 선수-그룹 관계 삭제
      await (delete(playerGroups)..where((tbl) => tbl.playerId.equals(playerId))).go();
      
      // 2. 선수 삭제
      await (delete(players)..where((tbl) => tbl.id.equals(playerId))).go();
    });
  }
}
