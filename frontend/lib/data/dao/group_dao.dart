import 'package:drift/drift.dart';
import '../database/tables.dart';
import '../database/app_database.dart';
import 'package:flutter/foundation.dart';

part 'group_dao.g.dart';

@DriftAccessor(tables: [Groups, PlayerGroups, Players])
class GroupDao extends DatabaseAccessor<AppDatabase> with _$GroupDaoMixin {
  GroupDao(super.db);

  Future<int> insertGroup(GroupsCompanion g) => into(groups).insert(g);

  Future<List<Group>> fetchAllGroups() => select(groups).get();

  /* 선수-그룹 매핑 추가 */
  Future<void> addPlayerToGroup(int playerId, int groupId) {
    if (kDebugMode) {
      print('DAO: 선수(ID: $playerId)를 그룹(ID: $groupId)에 추가 시도');
    }
    
    // 먼저 매핑이 이미 존재하는지 확인
    return transaction(() async {
      final existingMapping = await (select(playerGroups)
        ..where((tbl) => tbl.playerId.equals(playerId) & tbl.groupId.equals(groupId)))
        .getSingleOrNull();
        
      if (existingMapping != null) {
        if (kDebugMode) {
          print('DAO: 매핑이 이미 존재함 - $existingMapping');
        }
        
        // 수동으로 예외 발생
        throw Exception('UNIQUE constraint failed: 선수가 이미 그룹에 존재합니다.');
      }
      
      // 새로운 매핑 삽입
      if (kDebugMode) {
        print('DAO: 새 매핑 생성');
      }
      
      await into(playerGroups).insert(
        PlayerGroupsCompanion(
          playerId: Value(playerId), 
          groupId: Value(groupId)
        ),
      );
    });
  }

  /* 그룹 내 선수 수 카운트 */
  Future<int> countPlayersInGroup(int groupId) async {
    final res =
        await (selectOnly(playerGroups)
              ..addColumns([playerGroups.id.count()])
              ..where(playerGroups.groupId.equals(groupId)))
            .getSingle();
    return res.read(playerGroups.id.count()) ?? 0;
  }
  
  /* 그룹에 속한 선수 목록 조회 */
  Future<List<Player>> fetchPlayersInGroup(int groupId) {
    final query = select(players).join([
      innerJoin(
        playerGroups,
        playerGroups.playerId.equalsExp(players.id),
      ),
    ])
    ..where(playerGroups.groupId.equals(groupId));
    
    return query.map((row) => row.readTable(players)).get();
  }
  
  /* 그룹 삭제 */
  Future<int> deleteGroup(int groupId) {
    return transaction(() async {
      // 먼저 연결된 PlayerGroups 레코드 삭제
      await (delete(playerGroups)..where((tbl) => tbl.groupId.equals(groupId))).go();
      // 그룹 삭제
      return (delete(groups)..where((tbl) => tbl.id.equals(groupId))).go();
    });
  }
  
  /* 그룹에서 선수 제거 */
  Future<int> removePlayerFromGroup(int playerId, int groupId) {
    return (delete(playerGroups)
      ..where((tbl) => tbl.playerId.equals(playerId) & tbl.groupId.equals(groupId)))
      .go();
  }
}
