import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/match/get_matches_in_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_tournament_by_id_use_case.dart';
import 'package:bracket_helper/presentation/match/match_action.dart';
import 'package:bracket_helper/presentation/match/match_state.dart';
import 'package:bracket_helper/presentation/match/widgets/bracket_share_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 선수의 경기 통계 저장을 위한 클래스
class PlayerStats {
  final String playerName;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  int points = 0;
  int goalsFor = 0;    // 득점
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
  }) : _getTournamentByIdUseCase = getTournamentByIdUseCase,
       _getMatchesInTournamentUseCase = getMatchesInTournamentUseCase {
    init();
  }

  MatchState get state => _state;
  String get sortOption => _state.sortOption;  // getter는 state에서 가져옴
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
    final result = await _getMatchesInTournamentUseCase.execute(tournamentId);
    if (result.isSuccess) {
      _state = _state.copyWith(matches: result.value);
      final players = <PlayerModel>{};
      for (var match in result.value) {
        players.add(PlayerModel(id: 0, name: match.playerA!));
        players.add(PlayerModel(id: 0, name: match.playerB!));
        players.add(PlayerModel(id: 0, name: match.playerC!));
        players.add(PlayerModel(id: 0, name: match.playerD!));
      }
      _state = _state.copyWith(players: players.toList());
      
      // 매치 데이터가 있으면 통계 계산
      _calculatePlayerStats();
    } else {
      _state = _state.copyWith(errorMessage: result.error.toString());
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
        _state.tournament.losePoint
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
    // TODO: 대진표 섞기 로직 구현
    debugPrint('대진표 섞기 요청됨');
    // 프로토타입 구현 - 실제로는 API 호출이 필요함
  }
  
  // 정렬 옵션 변경
  void setSortOption(String option) {
    if (_state.sortOption != option) {
      _state = _state.copyWith(sortOption: option);  // state에 정렬 옵션 업데이트
      _sortPlayers();
      _notifyChanges();
    }
  }
  
  // 플레이어 정렬
  void _sortPlayers() {
    final sortedPlayers = [..._state.players];
    
    switch (_state.sortOption) {  // state의 sortOption 사용
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
          return statsB.goalDifference.compareTo(statsA.goalDifference); // 높은 득실차가 먼저 오도록
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
      case SortPlayersByName():
        setSortOption('name');
        break;
      case SortPlayersByPoints():
        setSortOption('points');
        break;
      case SortPlayersByDifference():
        setSortOption('difference');
        break;
    }
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
