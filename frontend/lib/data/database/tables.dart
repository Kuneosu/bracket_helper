import 'package:drift/drift.dart';

/* ──────────────── 1) 토너먼트 ──────────────── */
class Tournaments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get winPoint => integer().withDefault(const Constant(1))();
  IntColumn get drawPoint => integer().withDefault(const Constant(0))();
  IntColumn get losePoint => integer().withDefault(const Constant(0))();
  IntColumn get gamesPerPlayer => integer().withDefault(const Constant(4))();
  BoolColumn get isDoubles => boolean().withDefault(const Constant(true))();
  IntColumn get process => integer().withDefault(const Constant(0))();
}

/* ──────────────── 2) 그룹(폴더) ──────────────── */
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // 그룹 이름
  IntColumn get color => integer().nullable()(); // 그룹 대표 색상 (ARGB 값)
}

/* ──────────────── 3) 선수 ──────────────── */
class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

/* ──────────────── 4) 선수 ↔ 그룹 (N:M) ──────────────── */
class PlayerGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer().references(Players, #id)();
  IntColumn get groupId  => integer().references(Groups,  #id)();

  /* 동일 선수·그룹 중복 등록 방지 */
  @override
  List<Set<Column>> get uniqueKeys => [
        {playerId, groupId}
      ];
}

/* ──────────────── 5) 참가자(토너먼트 ↔ 선수 N:M) ──────────────── */
class Participants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tournamentId => integer().references(Tournaments, #id)();
  IntColumn get playerId     => integer().references(Players,     #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {tournamentId, playerId}
      ];
}

/* ──────────────── 6) 팀 ──────────────── */
class Teams extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get player1Id => integer().references(Players, #id)();
  IntColumn get player2Id =>
      integer().nullable().references(Players, #id)(); // 단식이면 NULL
}

/* ──────────────── 7) 경기 ──────────────── */
class Matches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tournamentId => integer().references(Tournaments, #id)();
  IntColumn get order        => integer()();                     // 경기 순서
  IntColumn get teamAId      => integer().references(Teams, #id)();
  IntColumn get teamBId      => integer().references(Teams, #id)();
  IntColumn get scoreA       => integer().nullable()();
  IntColumn get scoreB       => integer().nullable()();
}
