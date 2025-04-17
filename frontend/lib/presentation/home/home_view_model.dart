import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/tournament/delete_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_all_tournaments_use_case.dart';
import 'package:bracket_helper/presentation/home/home_action.dart';
import 'package:bracket_helper/presentation/home/home_state.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  final List<TournamentModel> _tournaments = [];
  HomeState _state = HomeState();
  HomeState get state => _state;
  final GetAllTournamentsUseCase _getAllTournamentsUseCase;
  final DeleteTournamentUseCase _deleteTournamentUseCase;

  List<TournamentModel> get tournaments => _tournaments;

  HomeViewModel({
    required GetAllTournamentsUseCase getAllTournamentsUseCase,
    required DeleteTournamentUseCase deleteTournamentUseCase,
  }) : _getAllTournamentsUseCase = getAllTournamentsUseCase,
       _deleteTournamentUseCase = deleteTournamentUseCase {
    fetchTournaments();
  }

  Future<void> fetchTournaments() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _getAllTournamentsUseCase.execute();

    if (result.isSuccess) {
      _tournaments.clear();
      _tournaments.addAll(result.value);
      _state = _state.copyWith(tournaments: result.value, isLoading: false);
    } else {
      // 오류 처리 - 필요에 따라 추가 구현
      _state = _state.copyWith(
        errorMessage: result.error.message,
        isLoading: false,
      );
    }

    notifyListeners();
  }

  Future<void> deleteTournament(int tournamentId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    final result = await _deleteTournamentUseCase.execute(tournamentId);
    if (result.isSuccess) {
      _tournaments.removeWhere((tournament) => tournament.id == tournamentId);
      notifyListeners();
    } else {
      // 오류 처리 - 필요에 따라 추가 구현
    }
    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  void onAction(HomeAction action) {
    switch (action) {
      case OnRefresh():
        fetchTournaments();
        break;
      case OnTapHelp():
        return;
      case OnTapAllTournament():
        return;
      case OnTapCreateTournament():
        return;
      case OnTapPlayerManagement():
        return;
      case OnTapGroupManagement():
        return;
      case OnTapStatistics():
        return;
      case OnTapMatchCard():
        return;
      case OnTapDeleteTournament():
        deleteTournament(action.tournamentId);
        break;
    }
  }
}
