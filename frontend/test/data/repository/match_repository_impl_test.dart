import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/repository/match_repository_impl.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/model/match_model.dart' as domain;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mock_dao/test_mock_match_dao.mocks.dart';

void main() {
  late MatchRepositoryImpl repository;
  late MockMatchDao mockMatchDao;

  setUp(() {
    mockMatchDao = MockMatchDao();
    repository = MatchRepositoryImpl(mockMatchDao);
  });

  group('createMatch 테스트', () {
    test('createMatch - 성공', () async {
      // given
      final tournamentId = 1;
      final teamAId = 1;
      final teamBId = 2;
      final teamAName = '팀A';
      final teamBName = '팀B';

      when(mockMatchDao.insertMatches(any)).thenAnswer((_) async => 1);

      // when
      final result = await repository.createMatch(
        tournamentId: tournamentId,
        teamAId: teamAId,
        teamBId: teamBId,
        teamAName: teamAName,
        teamBName: teamBName,
      );

      // then
      expect(result, isA<Result<domain.MatchModel>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value.tournamentId, tournamentId);
      expect(result.value.teamAId, teamAId);
      expect(result.value.teamBId, teamBId);
      expect(result.value.teamAName, teamAName);
      expect(result.value.teamBName, teamBName);

      verify(mockMatchDao.insertMatches(any)).called(1);
    });

    test('createMatch - 실패 (teamId null)', () async {
      // given
      final tournamentId = 1;

      // when
      final result = await repository.createMatch(
        tournamentId: tournamentId,
        teamAId: null,
        teamBId: 2,
      );

      // then
      expect(result, isA<Result<domain.MatchModel>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());

      verifyNever(mockMatchDao.insertMatches(any));
    });

    test('createMatch - 실패 (DB 오류)', () async {
      // given
      final tournamentId = 1;
      final teamAId = 1;
      final teamBId = 2;
      final exception = Exception('DB 오류');

      when(mockMatchDao.insertMatches(any)).thenThrow(exception);

      // when
      final result = await repository.createMatch(
        tournamentId: tournamentId,
        teamAId: teamAId,
        teamBId: teamBId,
      );

      // then
      expect(result, isA<Result<domain.MatchModel>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verify(mockMatchDao.insertMatches(any)).called(1);
    });
  });

  group('createMatches 테스트', () {
    test('createMatches - 성공', () async {
      // given
      final tournamentId = 1;
      final matchesData = [
        {
          'tournamentId': tournamentId,
          'teamAId': 1,
          'teamBId': 2,
          'teamAName': '팀A',
          'teamBName': '팀B',
          'order': 1,
        },
        {
          'tournamentId': tournamentId,
          'teamAId': 3,
          'teamBId': 4,
          'teamAName': '팀C',
          'teamBName': '팀D',
          'order': 2,
        },
      ];

      when(mockMatchDao.insertMatches(any)).thenAnswer((_) async => 1);

      // when
      final result = await repository.createMatches(matchesData);

      // then
      expect(result, isA<Result<List<domain.MatchModel>>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value.length, matchesData.length);

      verify(mockMatchDao.insertMatches(any)).called(1);
    });

    test('createMatches - 실패 (유효성 검증 오류)', () async {
      // given
      final tournamentId = 1;
      final matchesData = [
        {
          'tournamentId': tournamentId,
          'teamAId': null, // 유효하지 않은 데이터
          'teamBId': 2,
          'order': 1,
        },
      ];

      // when
      final result = await repository.createMatches(matchesData);

      // then
      expect(result, isA<Result<List<domain.MatchModel>>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verifyNever(mockMatchDao.insertMatches(any));
    });

    test('createMatches - 실패 (DB 오류)', () async {
      // given
      final tournamentId = 1;
      final matchesData = [
        {'tournamentId': tournamentId, 'teamAId': 1, 'teamBId': 2, 'order': 1},
      ];
      final exception = Exception('DB 오류');

      when(mockMatchDao.insertMatches(any)).thenThrow(exception);

      // when
      final result = await repository.createMatches(matchesData);

      // then
      expect(result, isA<Result<List<domain.MatchModel>>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verify(mockMatchDao.insertMatches(any)).called(1);
    });
  });

  group('fetchMatchesByTournament 테스트', () {
    test('fetchMatchesByTournament - 성공', () async {
      // given
      final tournamentId = 1;
      final matches = [
        domain.MatchModel(
          id: 1,
          tournamentId: tournamentId,
          teamAId: 1,
          teamBId: 2,
          teamAName: '팀A',
          teamBName: '팀B',
          order: 1,
        ),
      ];

      when(
        mockMatchDao.fetchMatchesByTournament(tournamentId),
      ).thenAnswer((_) async => matches);

      // when
      final result = await repository.fetchMatchesByTournament(tournamentId);

      // then
      expect(result, isA<Result<List<domain.MatchModel>>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, matches);

      verify(mockMatchDao.fetchMatchesByTournament(tournamentId)).called(1);
    });

    test('fetchMatchesByTournament - 실패', () async {
      // given
      final tournamentId = 1;
      final exception = Exception('DB 오류');

      when(
        mockMatchDao.fetchMatchesByTournament(tournamentId),
      ).thenThrow(exception);

      // when
      final result = await repository.fetchMatchesByTournament(tournamentId);

      // then
      expect(result, isA<Result<List<domain.MatchModel>>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verify(mockMatchDao.fetchMatchesByTournament(tournamentId)).called(1);
    });
  });

  group('updateScore 테스트', () {
    test('updateScore - 성공', () async {
      // given
      final matchId = 1;
      final scoreA = 21;
      final scoreB = 15;
      final matchFromDb = Matche(
        id: matchId,
        tournamentId: 1,
        teamAId: 1,
        teamBId: 2,
        order: 1,
        scoreA: scoreA,
        scoreB: scoreB,
      );

      when(
        mockMatchDao.updateScore(
          matchId: matchId,
          scoreA: scoreA,
          scoreB: scoreB,
        ),
      ).thenAnswer((_) async => null);

      when(mockMatchDao.getMatch(matchId)).thenAnswer((_) async => matchFromDb);

      // when
      final result = await repository.updateScore(
        matchId: matchId,
        scoreA: scoreA,
        scoreB: scoreB,
      );

      // then
      expect(result, isA<Result<domain.MatchModel>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value.id, matchId);
      expect(result.value.scoreA, scoreA);
      expect(result.value.scoreB, scoreB);

      verify(
        mockMatchDao.updateScore(
          matchId: matchId,
          scoreA: scoreA,
          scoreB: scoreB,
        ),
      ).called(1);
      verify(mockMatchDao.getMatch(matchId)).called(1);
    });

    test('updateScore - 실패 (매치를 찾을 수 없음)', () async {
      // given
      final matchId = 1;
      final scoreA = 21;
      final scoreB = 15;

      when(
        mockMatchDao.updateScore(
          matchId: matchId,
          scoreA: scoreA,
          scoreB: scoreB,
        ),
      ).thenAnswer((_) async => null);

      when(mockMatchDao.getMatch(matchId)).thenAnswer((_) async => null);

      // when
      final result = await repository.updateScore(
        matchId: matchId,
        scoreA: scoreA,
        scoreB: scoreB,
      );

      // then
      expect(result, isA<Result<domain.MatchModel>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verify(
        mockMatchDao.updateScore(
          matchId: matchId,
          scoreA: scoreA,
          scoreB: scoreB,
        ),
      ).called(1);
      verify(mockMatchDao.getMatch(matchId)).called(1);
    });

    test('updateScore - 실패 (DB 오류)', () async {
      // given
      final matchId = 1;
      final scoreA = 21;
      final scoreB = 15;
      final exception = Exception('DB 오류');

      when(
        mockMatchDao.updateScore(
          matchId: matchId,
          scoreA: scoreA,
          scoreB: scoreB,
        ),
      ).thenThrow(exception);

      // when
      final result = await repository.updateScore(
        matchId: matchId,
        scoreA: scoreA,
        scoreB: scoreB,
      );

      // then
      expect(result, isA<Result<domain.MatchModel>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verify(
        mockMatchDao.updateScore(
          matchId: matchId,
          scoreA: scoreA,
          scoreB: scoreB,
        ),
      ).called(1);
      verifyNever(mockMatchDao.getMatch(matchId));
    });
  });

  group('deleteMatch 테스트', () {
    test('deleteMatch - 성공', () async {
      // given
      final matchId = 1;
      final matchFromDb = Matche(
        id: matchId,
        tournamentId: 1,
        teamAId: 1,
        teamBId: 2,
        order: 1,
      );

      when(mockMatchDao.getMatch(matchId)).thenAnswer((_) async => matchFromDb);
      when(mockMatchDao.deleteMatch(matchId)).thenAnswer((_) async => 1);

      // when
      final result = await repository.deleteMatch(matchId);

      // then
      expect(result, isA<Result<Unit>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);

      verify(mockMatchDao.getMatch(matchId)).called(1);
      verify(mockMatchDao.deleteMatch(matchId)).called(1);
    });

    test('deleteMatch - 실패 (매치를 찾을 수 없음)', () async {
      // given
      final matchId = 1;

      when(mockMatchDao.getMatch(matchId)).thenAnswer((_) async => null);

      // when
      final result = await repository.deleteMatch(matchId);

      // then
      expect(result, isA<Result<Unit>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verify(mockMatchDao.getMatch(matchId)).called(1);
      verifyNever(mockMatchDao.deleteMatch(matchId));
    });

    test('deleteMatch - 실패 (삭제 실패)', () async {
      // given
      final matchId = 1;
      final matchFromDb = Matche(
        id: matchId,
        tournamentId: 1,
        teamAId: 1,
        teamBId: 2,
        order: 1,
      );

      when(mockMatchDao.getMatch(matchId)).thenAnswer((_) async => matchFromDb);
      when(mockMatchDao.deleteMatch(matchId)).thenAnswer((_) async => 0);

      // when
      final result = await repository.deleteMatch(matchId);

      // then
      expect(result, isA<Result<Unit>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verify(mockMatchDao.getMatch(matchId)).called(1);
      verify(mockMatchDao.deleteMatch(matchId)).called(1);
    });

    test('deleteMatch - 실패 (DB 오류)', () async {
      // given
      final matchId = 1;
      final exception = Exception('DB 오류');

      when(mockMatchDao.getMatch(matchId)).thenThrow(exception);

      // when
      final result = await repository.deleteMatch(matchId);

      // then
      expect(result, isA<Result<Unit>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, isA<DatabaseError>());

      verify(mockMatchDao.getMatch(matchId)).called(1);
      verifyNever(mockMatchDao.deleteMatch(matchId));
    });
  });
}
