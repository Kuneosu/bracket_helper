import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/repository/group_repository_impl.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:drift/drift.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mock_dao/test_mock_group_dao.mocks.dart';

void main() {
  late GroupRepositoryImpl repository;
  late MockGroupDao mockGroupDao;

  setUp(() {
    mockGroupDao = MockGroupDao();
    repository = GroupRepositoryImpl(mockGroupDao);
  });

  test('fetchAllGroups - 성공', () async {
    // given
    final groups = [Group(id: 1, name: '테스트 그룹')];
    when(mockGroupDao.fetchAllGroups()).thenAnswer((_) async => groups);

    // when
    final result = await repository.fetchAllGroups();

    // then
    expect(result, isA<Result<List<Group>>>());
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
  });

  test('fetchAllGroups - 실패', () async {
    // given
    final exception = Exception('DB 오류');
    when(mockGroupDao.fetchAllGroups()).thenThrow(exception);

    // when
    final result = await repository.fetchAllGroups();

    // then
    expect(result, isA<Result<List<Group>>>());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
  });

  test('addGroup - 성공', () async {
    // given
    final group = GroupsCompanion(name: const Value('새 그룹'));
    when(mockGroupDao.insertGroup(group)).thenAnswer((_) async => 1);

    // when
    final result = await repository.addGroup(group);

    // then
    expect(result, isA<Result<int>>());
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
  });

  test('addGroup - 실패', () async {
    // given
    final group = GroupsCompanion(name: const Value('새 그룹'));
    final exception = Exception('DB 오류');
    when(mockGroupDao.insertGroup(group)).thenThrow(exception);

    // when
    final result = await repository.addGroup(group);

    // then
    expect(result, isA<Result<int>>());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
  });

  test('addPlayerToGroup - 성공', () async {
    // given
    final playerId = 1;
    final groupId = 1;
    when(
      mockGroupDao.addPlayerToGroup(playerId, groupId),
    ).thenAnswer((_) async => 1);

    // when
    final result = await repository.addPlayerToGroup(playerId, groupId);

    // then
    expect(result, isA<Result<void>>());
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
  });

  test('addPlayerToGroup - 실패', () async {
    // given
    final playerId = 1;
    final groupId = 1;
    final exception = Exception('DB 오류');
    when(mockGroupDao.addPlayerToGroup(playerId, groupId)).thenThrow(exception);

    // when
    final result = await repository.addPlayerToGroup(playerId, groupId);

    // then
    expect(result, isA<Result<void>>());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
  });

  test('addPlayerToGroup - 유니크 제약 조건 위반', () async {
    // given
    final playerId = 1;
    final groupId = 1;
    final exception = Exception('UNIQUE constraint failed: 선수가 이미 그룹에 존재합니다.');
    when(mockGroupDao.addPlayerToGroup(playerId, groupId)).thenThrow(exception);

    // when
    final result = await repository.addPlayerToGroup(playerId, groupId);

    // then
    expect(result, isA<Result<void>>());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
    expect(result.error, isA<GroupError>());
  });

  test('fetchPlayersInGroup - 성공', () async {
    // given
    final groupId = 1;
    final players = [Player(id: 1, name: '테스트 선수')];
    when(
      mockGroupDao.fetchPlayersInGroup(groupId),
    ).thenAnswer((_) async => players);

    // when
    final result = await repository.fetchPlayersInGroup(groupId);

    // then
    expect(result, isA<Result<List<Player>>>());
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
    expect(result.value, players);
  });

  test('fetchPlayersInGroup - 실패', () async {
    // given
    final groupId = 1;
    final exception = Exception('DB 오류');
    when(mockGroupDao.fetchPlayersInGroup(groupId)).thenThrow(exception);

    // when
    final result = await repository.fetchPlayersInGroup(groupId);

    // then
    expect(result, isA<Result<List<Player>>>());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
  });

  test('deleteGroup - 성공', () async {
    // given
    final groupId = 1;
    when(mockGroupDao.deleteGroup(groupId)).thenAnswer((_) async => 1);

    // when
    final result = await repository.deleteGroup(groupId);

    // then
    expect(result, isA<Result<int>>());
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
    expect(result.value, 1);
  });

  test('deleteGroup - 실패', () async {
    // given
    final groupId = 1;
    final exception = Exception('DB 오류');
    when(mockGroupDao.deleteGroup(groupId)).thenThrow(exception);

    // when
    final result = await repository.deleteGroup(groupId);

    // then
    expect(result, isA<Result<int>>());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
  });

  test('removePlayerFromGroup - 성공', () async {
    // given
    final playerId = 1;
    final groupId = 1;
    when(
      mockGroupDao.removePlayerFromGroup(playerId, groupId),
    ).thenAnswer((_) async => 1);

    // when
    final result = await repository.removePlayerFromGroup(playerId, groupId);

    // then
    expect(result, isA<Result<int>>());
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
  });

  test('removePlayerFromGroup - 실패 (DB 오류)', () async {
    // given
    final playerId = 1;
    final groupId = 1;
    final exception = Exception('DB 오류');
    when(
      mockGroupDao.removePlayerFromGroup(playerId, groupId),
    ).thenThrow(exception);

    // when
    final result = await repository.removePlayerFromGroup(playerId, groupId);

    // then
    expect(result, isA<Result<int>>());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
  });

  test('removePlayerFromGroup - 선수가 그룹에 없음', () async {
    // given
    final playerId = 1;
    final groupId = 1;
    // 0은 영향 받은 행이 없음을 의미 (선수를 찾지 못함)
    when(
      mockGroupDao.removePlayerFromGroup(playerId, groupId),
    ).thenAnswer((_) async => 0);

    // when
    final result = await repository.removePlayerFromGroup(playerId, groupId);

    // then
    expect(result, isA<Result<int>>());
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
    expect(result.error, isA<GroupError>());
  });
}
