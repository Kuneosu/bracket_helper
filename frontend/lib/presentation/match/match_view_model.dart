import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/match/get_matches_in_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_tournament_by_id_use_case.dart';
import 'package:bracket_helper/presentation/match/match_state.dart';
import 'package:flutter/material.dart';

class MatchViewModel with ChangeNotifier {
  final int tournamentId;
  final GetTournamentByIdUseCase _getTournamentByIdUseCase;
  final GetMatchesInTournamentUseCase _getMatchesInTournamentUseCase;
  MatchState _state = MatchState(
    tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
  );

  MatchViewModel({
    required this.tournamentId,
    required GetTournamentByIdUseCase getTournamentByIdUseCase,
    required GetMatchesInTournamentUseCase getMatchesInTournamentUseCase,
  }) : _getTournamentByIdUseCase = getTournamentByIdUseCase,
       _getMatchesInTournamentUseCase = getMatchesInTournamentUseCase {
    init();
  }

  MatchState get state => _state;

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
}
