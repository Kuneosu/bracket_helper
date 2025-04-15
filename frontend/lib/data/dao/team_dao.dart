import 'package:drift/drift.dart';
import '../database/tables.dart';
import '../database/app_database.dart';

part 'team_dao.g.dart';

@DriftAccessor(tables: [Teams, Players])
class TeamDao extends DatabaseAccessor<AppDatabase> with _$TeamDaoMixin {
  TeamDao(super.db);

  Future<int> insertTeam(TeamsCompanion t) => into(teams).insert(t);

  Future<Team?> getTeam(int id) =>
      (select(teams)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      
  // 팀 목록 조회
  Future<List<Team>> fetchAllTeams() => select(teams).get();
  
  // 팀과 선수 정보를 함께 조회
  Future<List<TeamWithPlayers>> fetchTeamsWithPlayers() async {
    final allTeams = await select(teams).get();
    List<TeamWithPlayers> result = [];
    
    for (final team in allTeams) {
      final player1 = await (select(players)..where((p) => p.id.equals(team.player1Id))).getSingle();
      Player? player2;
      if (team.player2Id != null) {
        player2 = await (select(players)..where((p) => p.id.equals(team.player2Id!))).getSingleOrNull();
      }
      result.add(TeamWithPlayers(team, player1, player2));
    }
    
    return result;
  }
  
  // 팀 삭제
  Future<int> deleteTeam(int teamId) {
    return (delete(teams)..where((t) => t.id.equals(teamId))).go();
  }
}

// 팀과 플레이어 정보를 함께 담는 클래스
class TeamWithPlayers {
  final Team team;
  final Player player1;
  final Player? player2;
  
  TeamWithPlayers(this.team, this.player1, this.player2);
  
  String get teamName {
    if (player2 != null) {
      return '${player1.name} / ${player2!.name}';
    } else {
      return player1.name;
    }
  }
}
