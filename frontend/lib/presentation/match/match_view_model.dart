import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/match/create_match_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/delete_match_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/get_matches_in_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_tournament_by_id_use_case.dart';
import 'package:bracket_helper/presentation/match/match_action.dart';
import 'package:bracket_helper/presentation/match/match_state.dart';
import 'package:bracket_helper/presentation/match/widgets/bracket_share_utils.dart';
import 'package:bracket_helper/core/utils/bracket_scheduler.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 선수의 경기 통계 저장을 위한 클래스
class PlayerStats {
  final String playerName;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  int points = 0;
  int goalsFor = 0; // 득점
  int goalsAgainst = 0; // 실점

  PlayerStats(this.playerName);

  // 골득실차 계산
  int get goalDifference => goalsFor - goalsAgainst;

  // 총 경기 수
  int get totalGames => wins + draws + losses;

  // 승점 계산 (승, 무, 패에 따른 포인트 적용)
  void calculatePoints(int winPoint, int drawPoint, int losePoint) {
    points = (wins * winPoint) + (draws * drawPoint) + (losses * losePoint);
  }
}

class MatchViewModel with ChangeNotifier {
  final int tournamentId;
  final GetTournamentByIdUseCase _getTournamentByIdUseCase;
  final GetMatchesInTournamentUseCase _getMatchesInTournamentUseCase;
  final DeleteMatchUseCase _deleteMatchUseCase;
  final CreateMatchUseCase _createMatchUseCase;
  MatchState _state = MatchState(
    tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
  );

  // 플레이어별 통계 데이터
  final Map<String, PlayerStats> _playerStats = {};

  // sortOption은 state에서 관리

  MatchViewModel({
    required this.tournamentId,
    required GetTournamentByIdUseCase getTournamentByIdUseCase,
    required GetMatchesInTournamentUseCase getMatchesInTournamentUseCase,
    required DeleteMatchUseCase deleteMatchUseCase,
    required CreateMatchUseCase createMatchUseCase,
  }) : _getTournamentByIdUseCase = getTournamentByIdUseCase,
       _getMatchesInTournamentUseCase = getMatchesInTournamentUseCase,
       _deleteMatchUseCase = deleteMatchUseCase,
       _createMatchUseCase = createMatchUseCase {
    init();
  }

  MatchState get state => _state;
  String get sortOption => _state.sortOption; // getter는 state에서 가져옴
  Map<String, PlayerStats> get playerStats => _playerStats;

  Future<void> init() async {
    await loadTournament();
    await loadMatchesAndPlayers();
  }

  void _notifyChanges() {
    debugPrint('MatchViewModel: 상태 변경 알림');
    notifyListeners();
  }

  Future<void> loadTournament() async {
    _state = _state.copyWith(isLoading: true);
    _notifyChanges();
    final result = await _getTournamentByIdUseCase.execute(tournamentId);
    if (result.isSuccess) {
      _state = _state.copyWith(tournament: result.value);
    } else {
      _state = _state.copyWith(errorMessage: result.error.toString());
    }
    _state = _state.copyWith(isLoading: false);
    _notifyChanges();
  }

  Future<void> loadMatchesAndPlayers() async {
    _state = _state.copyWith(isLoading: true);
    _notifyChanges();
    
    debugPrint('토너먼트 ID $tournamentId의 매치 데이터 로드 시작');
    
    // DB에서 최신 매치 데이터 로드
    final result = await _getMatchesInTournamentUseCase.execute(tournamentId);
    
    if (result.isSuccess) {
      debugPrint('매치 데이터 로드 성공: ${result.value.length}개 매치');
      _state = _state.copyWith(matches: result.value);
      
      // 매치 데이터로부터 플레이어 목록 추출
      final players = <PlayerModel>{};
      
      for (var match in result.value) {
        if (match.playerA != null) players.add(PlayerModel(id: 0, name: match.playerA!));
        if (match.playerB != null) players.add(PlayerModel(id: 0, name: match.playerB!));
        if (match.playerC != null) players.add(PlayerModel(id: 0, name: match.playerC!));
        if (match.playerD != null) players.add(PlayerModel(id: 0, name: match.playerD!));
      }
      
      debugPrint('추출된 플레이어 수: ${players.length}명');
      _state = _state.copyWith(players: players.toList());

      // 매치 데이터가 있으면 통계 계산
      _calculatePlayerStats();
    } else {
      debugPrint('매치 데이터 로드 실패: ${result.error}');
      _state = _state.copyWith(
        errorMessage: '매치 데이터를 불러오는데 실패했습니다: ${result.error}',
        matches: [], // 실패 시 빈 목록으로 초기화
        players: [], // 실패 시 빈 목록으로 초기화
      );
    }
    
    _state = _state.copyWith(isLoading: false);
    _notifyChanges();
  }

  /// 모든 플레이어의 통계를 계산
  void _calculatePlayerStats() {
    // 통계 초기화
    _playerStats.clear();

    // 모든 플레이어에 대해 통계 객체 생성
    for (var player in _state.players) {
      _playerStats[player.name] = PlayerStats(player.name);
    }

    // 각 매치에 대해 결과 계산
    for (var match in _state.matches) {
      // 결과가 없는 경기는 건너뜀
      if (!match.hasResult) continue;

      // A팀 선수 통계 업데이트
      _updateTeamAStats(match);

      // B팀 선수 통계 업데이트
      _updateTeamBStats(match);
    }

    // 최종 승점 계산
    for (var stats in _playerStats.values) {
      stats.calculatePoints(
        _state.tournament.winPoint,
        _state.tournament.drawPoint,
        _state.tournament.losePoint,
      );
    }
  }

  /// A팀(playerA, playerC) 통계 업데이트
  void _updateTeamAStats(MatchModel match) {
    if (_playerStats.containsKey(match.playerA)) {
      final statsA = _playerStats[match.playerA]!;

      // 득실점 기록
      statsA.goalsFor += match.scoreA ?? 0;
      statsA.goalsAgainst += match.scoreB ?? 0;

      // 승패무 기록
      if (match.isDraw) {
        statsA.draws++;
      } else if (match.isTeamAWinner) {
        statsA.wins++;
      } else {
        statsA.losses++;
      }
    }

    // 더블스인 경우 playerC도 업데이트
    if (_playerStats.containsKey(match.playerC)) {
      final statsC = _playerStats[match.playerC]!;

      // 득실점 기록
      statsC.goalsFor += match.scoreA ?? 0;
      statsC.goalsAgainst += match.scoreB ?? 0;

      // 승패무 기록
      if (match.isDraw) {
        statsC.draws++;
      } else if (match.isTeamAWinner) {
        statsC.wins++;
      } else {
        statsC.losses++;
      }
    }
  }

  /// B팀(playerB, playerD) 통계 업데이트
  void _updateTeamBStats(MatchModel match) {
    if (_playerStats.containsKey(match.playerB)) {
      final statsB = _playerStats[match.playerB]!;

      // 득실점 기록
      statsB.goalsFor += match.scoreB ?? 0;
      statsB.goalsAgainst += match.scoreA ?? 0;

      // 승패무 기록
      if (match.isDraw) {
        statsB.draws++;
      } else if (match.isTeamBWinner) {
        statsB.wins++;
      } else {
        statsB.losses++;
      }
    }

    // 더블스인 경우 playerD도 업데이트
    if (_playerStats.containsKey(match.playerD)) {
      final statsD = _playerStats[match.playerD]!;

      // 득실점 기록
      statsD.goalsFor += match.scoreB ?? 0;
      statsD.goalsAgainst += match.scoreA ?? 0;

      // 승패무 기록
      if (match.isDraw) {
        statsD.draws++;
      } else if (match.isTeamBWinner) {
        statsD.wins++;
      } else {
        statsD.losses++;
      }
    }
  }

  // 점수 업데이트 함수
  Future<void> updateScore(int matchId, int? scoreA, int? scoreB) async {
    // TODO: 실제 점수 업데이트 로직 구현 필요
    debugPrint('매치 ID $matchId 점수 업데이트: A=$scoreA, B=$scoreB');

    // 프로토타입 구현 - 실제로는 API 호출이 필요함
    final updatedMatches = [..._state.matches];
    final matchIndex = updatedMatches.indexWhere((m) => m.id == matchId);

    if (matchIndex != -1) {
      final match = updatedMatches[matchIndex];
      updatedMatches[matchIndex] = match.copyWith(
        scoreA: scoreA,
        scoreB: scoreB,
      );

      _state = _state.copyWith(matches: updatedMatches);

      // 점수가 업데이트되면 통계 다시 계산
      _calculatePlayerStats();

      _notifyChanges();
    }
  }

  // 대진표 섞기 기능
  Future<void> shuffleBracket() async {
    debugPrint('대진표 섞기 요청됨');

    _state = _state.copyWith(isLoading: true);
    _notifyChanges();

    try {
      // 1. 현재 플레이어 목록을 무작위로 섞습니다
      final Random random = Random();
      final shuffledPlayers = [..._state.players]..shuffle(random);

      debugPrint('선수 목록 섞기 완료: ${shuffledPlayers.length}명');

      // 유효성 검사: 선수가 최소 4명 이상이어야 함
      if (shuffledPlayers.length < 4) {
        debugPrint('오류: 선수가 부족합니다 (${shuffledPlayers.length}명, 최소 4명 필요)');
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: '대진표 생성을 위해 최소 4명의 선수가 필요합니다.',
        );
        _notifyChanges();
        return;
      }

      // 2. BracketScheduler를 사용하여 새 매치를 생성합니다
      final int courts = shuffledPlayers.length ~/ 4;
      final int gamesPerPlayer = _state.tournament.gamesPerPlayer;

      debugPrint('대진표 생성 시작 - 코트 수: $courts, 선수당 경기 수: $gamesPerPlayer');

      final List<MatchModel> newMatches = BracketScheduler.generate(
        shuffledPlayers,
        courts: courts,
        gamesPer: gamesPerPlayer,
      );

      debugPrint('새 대진표 생성 완료: ${newMatches.length}개 매치');

      // 3. 기존 매치 삭제 및 새 매치 저장
      await _deleteExistingMatches();
      await _createNewMatches(newMatches);

      // 4. 상태 업데이트 및 매치와 플레이어 목록 다시 로드
      await loadMatchesAndPlayers();
    } catch (e) {
      debugPrint('대진표 섞기 중 오류 발생: $e');
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: '대진표 섞기 중 오류가 발생했습니다: $e',
      );
      _notifyChanges();
    }
  }

  // 기존 매치 삭제
  Future<void> _deleteExistingMatches() async {
    debugPrint('기존 매치 삭제 시작');

    for (final match in _state.matches) {
      debugPrint('매치 ID ${match.id} 삭제 중...');
      final result = await _deleteMatchUseCase.execute(match.id);

      if (!result.isSuccess) {
        debugPrint('매치 ID ${match.id} 삭제 실패: ${result.error}');
        // 삭제에 실패해도 계속 진행 (ID가 없는 경우 등 무시)
      }
    }

    debugPrint('기존 매치 삭제 완료');
  }

  // 새 매치 생성
  Future<void> _createNewMatches(List<MatchModel> matches) async {
    debugPrint('${matches.length}개의 새 매치 생성 시작');

    try {
      // 모든 매치에 현재 토너먼트 ID와 기본 점수를 설정
      final List<MatchModel> updatedMatches =
          matches.map((match) {
            return match.copyWith(
              tournamentId: tournamentId,
              scoreA: 0, // 기본 점수 설정
              scoreB: 0, // 기본 점수 설정
            );
          }).toList();

      // 매치 데이터를 Map으로 변환하여 저장
      final futures = <Future<dynamic>>[];

      // 각 매치에 대해 비동기 작업 실행
      for (final match in updatedMatches) {
        debugPrint(
          '매치 생성 요청 - 토너먼트 ID: ${match.tournamentId}, 선수A: ${match.playerA}, 선수B: ${match.playerB}, 선수C: ${match.playerC}, 선수D: ${match.playerD}',
        );
        futures.add(_createMatchUseCase.execute(match));
      }

      // 모든 Future가 완료될 때까지 기다림
      final results = await Future.wait(futures);

      final successCount = results.where((result) => result.isSuccess).length;
      final failureCount = results.where((result) => !result.isSuccess).length;

      if (failureCount == 0) {
        debugPrint('새 매치 일괄 생성 성공: $successCount개');
      } else {
        debugPrint('일부 매치 생성 실패: $failureCount개 실패, $successCount개 성공');

        // 첫 번째 실패한 결과의 오류 메시지 가져오기
        final firstFailure = results.firstWhere((result) => !result.isSuccess);
        throw Exception('새 대진표를 생성하는데 실패했습니다: ${firstFailure.error.message}');
      }
    } catch (e) {
      debugPrint('새 매치 생성 중 오류: $e');
      rethrow; // 상위 메서드로 예외 전파
    }
  }

  // 정렬 옵션 변경
  void setSortOption(String option) {
    if (_state.sortOption != option) {
      _state = _state.copyWith(sortOption: option); // state에 정렬 옵션 업데이트
      _sortPlayers();
      _notifyChanges();
    }
  }

  // 플레이어 정렬
  void _sortPlayers() {
    final sortedPlayers = [..._state.players];

    switch (_state.sortOption) {
      // state의 sortOption 사용
      case 'name':
        sortedPlayers.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'points':
        sortedPlayers.sort((a, b) {
          final statsA = _playerStats[a.name];
          final statsB = _playerStats[b.name];
          if (statsA == null || statsB == null) return 0;
          return statsB.points.compareTo(statsA.points); // 높은 점수가 먼저 오도록
        });
        break;
      case 'difference':
        sortedPlayers.sort((a, b) {
          final statsA = _playerStats[a.name];
          final statsB = _playerStats[b.name];
          if (statsA == null || statsB == null) return 0;
          return statsB.goalDifference.compareTo(
            statsA.goalDifference,
          ); // 높은 득실차가 먼저 오도록
        });
        break;
    }

    _state = _state.copyWith(players: sortedPlayers);
  }

  // MatchAction을 처리하는 함수
  void onAction(MatchAction action, BuildContext context) {
    switch (action) {
      case UpdateScore():
        updateScore(action.matchId, action.scoreA, action.scoreB);
        break;
      case CaptureAndShareBracket():
        captureBracketAndShare(context);
        break;
      case ShuffleBracket():
        shuffleBracket();
        break;
      case FinishTournament():
        context.go(RoutePaths.home);
        break;
      case SortPlayersBy():
        setSortOption(action.sortOption);
        break;
      case EditBracket():
        editBracket(context);
        break;
    }
  }

  // 대진표 수정 화면으로 이동
  void editBracket(BuildContext context) {
    debugPrint('대진표 수정 화면으로 이동: ${_state.tournament.id}');

    // 대진 수정 화면으로 이동
    context.go(
      '${RoutePaths.createTournament}${RoutePaths.editMatch}',
      extra: {
        'tournament': _state.tournament,
        'players': _state.players,
        'matches': _state.matches,
      },
    );
  }

  // 대진표 캡처 및 공유
  Future<void> captureBracketAndShare(BuildContext context) async {
    await BracketShareUtils.captureBracketAndShare(
      context: context,
      tournament: _state.tournament,
      matches: _state.matches,
      players: _state.players,
    );
  }

  // 토너먼트 종료 처리
  Future<void> finishTournament() async {
    // TODO: 토너먼트 종료 로직 구현
    debugPrint('토너먼트 ID $tournamentId 종료 요청됨');
    // 프로토타입 구현 - 실제로는 API 호출이 필요함
  }
}
