import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';

// 테스트용 메모리 데이터베이스를 생성하는 함수
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory(
    setup: (rawDb) {
      rawDb.execute('PRAGMA foreign_keys = ON');
    },
  ));
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = createTestDatabase();
  });

  tearDown(() async {
    await database.close();
  });

  group('스키마 테스트', () {
    test('데이터베이스가 성공적으로 초기화되어야 함', () {
      // 데이터베이스 객체 생성 자체가 성공적으로 완료되면 테스트 통과
      expect(database, isA<AppDatabase>());
      expect(database.schemaVersion, 1); // 스키마 버전 확인
    });
  });

  group('Tournaments 테이블 CRUD 테스트', () {
    test('토너먼트 생성/조회/수정/삭제', () async {
      // 1. 생성 (Create)
      final tournamentId = await database
          .into(database.tournaments)
          .insert(
            TournamentsCompanion.insert(
              title: '테스트 토너먼트',
              date: DateTime.now(),
              winPoint: const Value(3),
              drawPoint: const Value(1),
              losePoint: const Value(0),
              gamesPerPlayer: const Value(5),
              isDoubles: const Value(true),
            ),
          );

      expect(tournamentId, 1); // 첫 번째 레코드는 ID가 1이어야 함

      // 2. 조회 (Read)
      final tournament =
          await (database.select(database.tournaments)
            ..where((t) => t.id.equals(tournamentId))).getSingle();
      expect(tournament.title, '테스트 토너먼트');
      expect(tournament.winPoint, 3);
      expect(tournament.drawPoint, 1);
      expect(tournament.losePoint, 0);
      expect(tournament.gamesPerPlayer, 5);
      expect(tournament.isDoubles, true);

      // 3. 수정 (Update)
      await (database.update(database.tournaments)..where(
        (t) => t.id.equals(tournamentId),
      )).write(const TournamentsCompanion(title: Value('수정된 토너먼트')));

      final updatedTournament =
          await (database.select(database.tournaments)
            ..where((t) => t.id.equals(tournamentId))).getSingle();
      expect(updatedTournament.title, '수정된 토너먼트');

      // 4. 삭제 (Delete)
      final deletedRows =
          await (database.delete(database.tournaments)
            ..where((t) => t.id.equals(tournamentId))).go();
      expect(deletedRows, 1); // 한 개의 행이 삭제되어야 함

      // 삭제 확인
      final remainingTournaments =
          await database.select(database.tournaments).get();
      expect(remainingTournaments.length, 0);
    });
  });

  group('Players 테이블 CRUD 테스트', () {
    test('선수 생성/조회/수정/삭제', () async {
      // 1. 생성 (Create)
      final playerId = await database
          .into(database.players)
          .insert(PlayersCompanion.insert(name: '홍길동'));

      expect(playerId, 1);

      // 2. 조회 (Read)
      final player =
          await (database.select(database.players)
            ..where((p) => p.id.equals(playerId))).getSingle();
      expect(player.name, '홍길동');

      // 3. 수정 (Update)
      await (database.update(database.players)..where(
        (p) => p.id.equals(playerId),
      )).write(const PlayersCompanion(name: Value('김철수')));

      final updatedPlayer =
          await (database.select(database.players)
            ..where((p) => p.id.equals(playerId))).getSingle();
      expect(updatedPlayer.name, '김철수');

      // 4. 삭제 (Delete)
      final deletedRows =
          await (database.delete(database.players)
            ..where((p) => p.id.equals(playerId))).go();
      expect(deletedRows, 1);

      final remainingPlayers = await database.select(database.players).get();
      expect(remainingPlayers.length, 0);
    });
  });

  group('외래 키 제약 조건 테스트', () {
    test('토너먼트와 매치 간의 관계 테스트', () async {
      // 1. 토너먼트 생성
      final tournamentId = await database
          .into(database.tournaments)
          .insert(
            TournamentsCompanion.insert(title: '토너먼트', date: DateTime.now()),
          );

      // 2. 선수 두 명 생성
      final player1Id = await database
          .into(database.players)
          .insert(PlayersCompanion.insert(name: '선수1'));

      final player2Id = await database
          .into(database.players)
          .insert(PlayersCompanion.insert(name: '선수2'));

      // 3. 팀 생성 (두 개)
      final teamAId = await database
          .into(database.teams)
          .insert(
            TeamsCompanion.insert(
              player1Id: player1Id,
              player2Id: Value(null), // 단식으로 설정
            ),
          );

      final teamBId = await database
          .into(database.teams)
          .insert(
            TeamsCompanion.insert(
              player1Id: player2Id,
              player2Id: Value(null), // 단식으로 설정
            ),
          );

      // 4. 매치 생성
      final matchId = await database
          .into(database.matches)
          .insert(
            MatchesCompanion.insert(
              tournamentId: tournamentId,
              order: 1,
              teamAId: teamAId,
              teamBId: teamBId,
              scoreA: const Value(21),
              scoreB: const Value(19),
            ),
          );

      // 5. 데이터 검증
      final match =
          await (database.select(database.matches)
            ..where((m) => m.id.equals(matchId))).getSingle();
      expect(match.tournamentId, tournamentId);
      expect(match.teamAId, teamAId);
      expect(match.teamBId, teamBId);
      expect(match.scoreA, 21);
      expect(match.scoreB, 19);

      // 6. 외래 키 제약 조건 검증
      // 외래 키 제약 조건으로 인해 토너먼트를 삭제하기 전에 먼저 매치를 삭제해야 함
      expect(
        () => (database.delete(database.tournaments)..where((t) => t.id.equals(tournamentId))).go(),
        throwsA(isA<SqliteException>()),
      );

      // 7. 매치를 먼저 삭제
      final deletedMatchCount = await (database.delete(database.matches)
        ..where((m) => m.tournamentId.equals(tournamentId))).go();
      expect(deletedMatchCount, 1);

      // 8. 이제 토너먼트를 삭제할 수 있음
      final deletedTournamentCount = await (database.delete(database.tournaments)
        ..where((t) => t.id.equals(tournamentId))).go();
      expect(deletedTournamentCount, 1);

      // 9. 매치와 토너먼트가 모두 삭제되었는지 확인
      final remainingMatches = await (database.select(database.matches)
        ..where((m) => m.tournamentId.equals(tournamentId))).get();
      expect(remainingMatches.length, 0);

      final remainingTournaments = await (database.select(database.tournaments)
        ..where((t) => t.id.equals(tournamentId))).get();
      expect(remainingTournaments.length, 0);
    });
  });

  group('트랜잭션 테스트', () {
    test('여러 레코드를 함께 삽입하는 트랜잭션이 성공해야 함', () async {
      // 트랜잭션 실행
      await database.transaction(() async {
        // 선수 생성
        final player1Id = await database
            .into(database.players)
            .insert(PlayersCompanion.insert(name: '트랜잭션 선수1'));

        final player2Id = await database
            .into(database.players)
            .insert(PlayersCompanion.insert(name: '트랜잭션 선수2'));

        // 그룹 생성
        final groupId = await database
            .into(database.groups)
            .insert(GroupsCompanion.insert(name: '트랜잭션 그룹'));

        // 선수-그룹 연결
        await database
            .into(database.playerGroups)
            .insert(
              PlayerGroupsCompanion.insert(
                playerId: player1Id,
                groupId: groupId,
              ),
            );

        await database
            .into(database.playerGroups)
            .insert(
              PlayerGroupsCompanion.insert(
                playerId: player2Id,
                groupId: groupId,
              ),
            );
      });

      // 트랜잭션 결과 검증
      final players = await database.select(database.players).get();
      expect(players.length, 2);

      final groups = await database.select(database.groups).get();
      expect(groups.length, 1);

      final playerGroups = await database.select(database.playerGroups).get();
      expect(playerGroups.length, 2);
    });
  });

  group('고유 제약 조건 테스트', () {
    test('PlayerGroups 테이블에서 동일한 playerId와 groupId 조합의 중복 방지', () async {
      // 선수 생성
      final playerId = await database
          .into(database.players)
          .insert(PlayersCompanion.insert(name: '중복 테스트 선수'));

      // 그룹 생성
      final groupId = await database
          .into(database.groups)
          .insert(GroupsCompanion.insert(name: '중복 테스트 그룹'));

      // 첫 번째 삽입 (성공)
      await database
          .into(database.playerGroups)
          .insert(
            PlayerGroupsCompanion.insert(playerId: playerId, groupId: groupId),
          );

      // 두 번째 삽입 (동일한 조합이므로 실패해야 함)
      expect(
        () => database
            .into(database.playerGroups)
            .insert(
              PlayerGroupsCompanion.insert(
                playerId: playerId,
                groupId: groupId,
              ),
            ),
        throwsA(anything), // 고유 제약 조건 위반 예외가 발생해야 함
      );
    });
  });
}
