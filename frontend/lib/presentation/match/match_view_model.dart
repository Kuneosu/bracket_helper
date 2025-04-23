import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/match/get_matches_in_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_tournament_by_id_use_case.dart';
import 'package:bracket_helper/presentation/match/match_action.dart';
import 'package:bracket_helper/presentation/match/match_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bracket_helper/presentation/match/widgets/bracket_share_utils.dart';

class MatchViewModel with ChangeNotifier {
  final int tournamentId;
  final GetTournamentByIdUseCase _getTournamentByIdUseCase;
  final GetMatchesInTournamentUseCase _getMatchesInTournamentUseCase;
  MatchState _state = MatchState(
    tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
  );
  
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
    } else {
      _state = _state.copyWith(errorMessage: result.error.toString());
    }
    _state = _state.copyWith(isLoading: false);
    _notifyChanges();
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
        // 포인트 기준 정렬 - 실제 구현 필요
        break;
      case 'difference':
        // 득실차 기준 정렬 - 실제 구현 필요
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
