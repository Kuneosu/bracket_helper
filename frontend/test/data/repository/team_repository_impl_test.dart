import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/repository/team_repository_impl.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/data/dao/team_dao.dart';
import 'package:drift/drift.dart' hide isNull;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mock_dao/test_mock_team_dao.mocks.dart';

void main() {
  late TeamRepositoryImpl repository;
  late MockTeamDao mockTeamDao;

  setUp(() {
    mockTeamDao = MockTeamDao();
    repository = TeamRepositoryImpl(mockTeamDao);
  });

  group('createTeam 테스트', () {
    test('createTeam - 성공', () async {
      // given
      final team = TeamsCompanion(
        player1Id: const Value(1),
        player2Id: const Value(2),
      );
      final teamId = 1;
      
      when(mockTeamDao.insertTeam(team)).thenAnswer((_) async => teamId);
      
      // when
      final result = await repository.createTeam(team);
      
      // then
      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, teamId);
      
      verify(mockTeamDao.insertTeam(team)).called(1);
    });
    
    test('createTeam - 실패', () async {
      // given
      final team = TeamsCompanion(
        player1Id: const Value(1),
        player2Id: const Value(2),
      );
      final exception = Exception('DB 오류');
      
      when(mockTeamDao.insertTeam(team)).thenThrow(exception);
      
      // when
      final result = await repository.createTeam(team);
      
      // then
      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockTeamDao.insertTeam(team)).called(1);
    });
  });
  
  group('deleteTeam 테스트', () {
    test('deleteTeam - 성공', () async {
      // given
      final teamId = 1;
      
      when(mockTeamDao.deleteTeam(teamId)).thenAnswer((_) async => 1);
      
      // when
      final result = await repository.deleteTeam(teamId);
      
      // then
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      
      verify(mockTeamDao.deleteTeam(teamId)).called(1);
    });
    
    test('deleteTeam - 실패', () async {
      // given
      final teamId = 1;
      final exception = Exception('DB 오류');
      
      when(mockTeamDao.deleteTeam(teamId)).thenThrow(exception);
      
      // when
      final result = await repository.deleteTeam(teamId);
      
      // then
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockTeamDao.deleteTeam(teamId)).called(1);
    });
  });
  
  group('fetchAllTeams 테스트', () {
    test('fetchAllTeams - 성공', () async {
      // given
      final teams = [
        Team(id: 1, player1Id: 1, player2Id: 2),
        Team(id: 2, player1Id: 3, player2Id: 4),
      ];
      
      when(mockTeamDao.fetchAllTeams()).thenAnswer((_) async => teams);
      
      // when
      final result = await repository.fetchAllTeams();
      
      // then
      expect(result, isA<Result<List<Team>>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, teams);
      
      verify(mockTeamDao.fetchAllTeams()).called(1);
    });
    
    test('fetchAllTeams - 실패', () async {
      // given
      final exception = Exception('DB 오류');
      
      when(mockTeamDao.fetchAllTeams()).thenThrow(exception);
      
      // when
      final result = await repository.fetchAllTeams();
      
      // then
      expect(result, isA<Result<List<Team>>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockTeamDao.fetchAllTeams()).called(1);
    });
  });
  
  group('fetchTeamsWithPlayers 테스트', () {
    test('fetchTeamsWithPlayers - 성공', () async {
      // given
      final teamsWithPlayers = [
        TeamWithPlayers(
          Team(id: 1, player1Id: 1, player2Id: 2),
          Player(id: 1, name: '홍길동'),
          Player(id: 2, name: '김철수')
        ),
        TeamWithPlayers(
          Team(id: 2, player1Id: 3, player2Id: 4),
          Player(id: 3, name: '이영희'),
          Player(id: 4, name: '박지성')
        ),
      ];
      
      when(mockTeamDao.fetchTeamsWithPlayers()).thenAnswer((_) async => teamsWithPlayers);
      
      // when
      final result = await repository.fetchTeamsWithPlayers();
      
      // then
      expect(result, isA<Result<List<dynamic>>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, teamsWithPlayers);
      
      verify(mockTeamDao.fetchTeamsWithPlayers()).called(1);
    });
    
    test('fetchTeamsWithPlayers - 실패', () async {
      // given
      final exception = Exception('DB 오류');
      
      when(mockTeamDao.fetchTeamsWithPlayers()).thenThrow(exception);
      
      // when
      final result = await repository.fetchTeamsWithPlayers();
      
      // then
      expect(result, isA<Result<List<dynamic>>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockTeamDao.fetchTeamsWithPlayers()).called(1);
    });
  });
  
  group('getTeam 테스트', () {
    test('getTeam - 성공 (팀 찾음)', () async {
      // given
      final teamId = 1;
      final team = Team(id: teamId, player1Id: 1, player2Id: 2);
      
      when(mockTeamDao.getTeam(teamId)).thenAnswer((_) async => team);
      
      // when
      final result = await repository.getTeam(teamId);
      
      // then
      expect(result, isA<Result<Team?>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      
      if (result.isSuccess) {
        expect(result.value, team);
      }
      
      verify(mockTeamDao.getTeam(teamId)).called(1);
    });
    
    test('getTeam - 실패 (DB 오류)', () async {
      // given
      final teamId = 1;
      final exception = Exception('DB 오류');
      
      when(mockTeamDao.getTeam(teamId)).thenThrow(exception);
      
      // when
      final result = await repository.getTeam(teamId);
      
      // then
      expect(result, isA<Result<Team?>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockTeamDao.getTeam(teamId)).called(1);
    });
  });
} 