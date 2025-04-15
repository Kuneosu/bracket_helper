import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/repository/player_repository_impl.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:drift/drift.dart' hide isNull;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mock_dao/test_mock_player_dao.mocks.dart';

void main() {
  late PlayerRepositoryImpl repository;
  late MockPlayerDao mockPlayerDao;

  setUp(() {
    mockPlayerDao = MockPlayerDao();
    repository = PlayerRepositoryImpl(mockPlayerDao);
  });

  group('addPlayer 테스트', () {
    test('addPlayer - 성공', () async {
      // given
      final player = PlayersCompanion(name: const Value('홍길동'));
      final playerId = 1;
      
      when(mockPlayerDao.upsertPlayer(player)).thenAnswer((_) async => playerId);
      
      // when
      final result = await repository.addPlayer(player);
      
      // then
      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, playerId);
      
      verify(mockPlayerDao.upsertPlayer(player)).called(1);
    });
    
    test('addPlayer - 실패', () async {
      // given
      final player = PlayersCompanion(name: const Value('홍길동'));
      final exception = Exception('DB 오류');
      
      when(mockPlayerDao.upsertPlayer(player)).thenThrow(exception);
      
      // when
      final result = await repository.addPlayer(player);
      
      // then
      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockPlayerDao.upsertPlayer(player)).called(1);
    });
  });
  
  group('deletePlayer 테스트', () {
    test('deletePlayer - 성공', () async {
      // given
      final playerId = 1;
      
      when(mockPlayerDao.deletePlayer(playerId)).thenAnswer((_) async => null);
      
      // when
      final result = await repository.deletePlayer(playerId);
      
      // then
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      
      verify(mockPlayerDao.deletePlayer(playerId)).called(1);
    });
    
    test('deletePlayer - 실패', () async {
      // given
      final playerId = 1;
      final exception = Exception('DB 오류');
      
      when(mockPlayerDao.deletePlayer(playerId)).thenThrow(exception);
      
      // when
      final result = await repository.deletePlayer(playerId);
      
      // then
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockPlayerDao.deletePlayer(playerId)).called(1);
    });
  });
  
  group('fetchAllPlayers 테스트', () {
    test('fetchAllPlayers - 성공', () async {
      // given
      final players = [
        Player(id: 1, name: '홍길동'),
        Player(id: 2, name: '김철수'),
      ];
      
      when(mockPlayerDao.fetchAllPlayers()).thenAnswer((_) async => players);
      
      // when
      final result = await repository.fetchAllPlayers();
      
      // then
      expect(result, isA<Result<List<Player>>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, players);
      
      verify(mockPlayerDao.fetchAllPlayers()).called(1);
    });
    
    test('fetchAllPlayers - 실패', () async {
      // given
      final exception = Exception('DB 오류');
      
      when(mockPlayerDao.fetchAllPlayers()).thenThrow(exception);
      
      // when
      final result = await repository.fetchAllPlayers();
      
      // then
      expect(result, isA<Result<List<Player>>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockPlayerDao.fetchAllPlayers()).called(1);
    });
  });
  
  group('getPlayer 테스트', () {
    test('getPlayer - 성공 (선수 찾음)', () async {
      // given
      final playerId = 1;
      final player = Player(id: playerId, name: '홍길동');
      
      when(mockPlayerDao.getPlayer(playerId)).thenAnswer((_) async => player);
      
      // when
      final result = await repository.getPlayer(playerId);
      
      // then
      expect(result, isA<Result<Player?>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      
      if (result.isSuccess) {
        expect(result.value, player);
      }
      
      verify(mockPlayerDao.getPlayer(playerId)).called(1);
    });
    
    test('getPlayer - 실패 (DB 오류)', () async {
      // given
      final playerId = 1;
      final exception = Exception('DB 오류');
      
      when(mockPlayerDao.getPlayer(playerId)).thenThrow(exception);
      
      // when
      final result = await repository.getPlayer(playerId);
      
      // then
      expect(result, isA<Result<Player?>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockPlayerDao.getPlayer(playerId)).called(1);
    });
  });
  
  group('updatePlayer 테스트', () {
    test('updatePlayer - 성공', () async {
      // given
      final player = PlayersCompanion(
        id: const Value(1),
        name: const Value('홍길동 (수정)'),
      );
      final playerId = 1;
      
      when(mockPlayerDao.upsertPlayer(player)).thenAnswer((_) async => playerId);
      
      // when
      final result = await repository.updatePlayer(player);
      
      // then
      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, playerId);
      
      verify(mockPlayerDao.upsertPlayer(player)).called(1);
    });
    
    test('updatePlayer - 실패', () async {
      // given
      final player = PlayersCompanion(
        id: const Value(1),
        name: const Value('홍길동 (수정)'),
      );
      final exception = Exception('DB 오류');
      
      when(mockPlayerDao.upsertPlayer(player)).thenThrow(exception);
      
      // when
      final result = await repository.updatePlayer(player);
      
      // then
      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());
      
      verify(mockPlayerDao.upsertPlayer(player)).called(1);
    });
  });
} 