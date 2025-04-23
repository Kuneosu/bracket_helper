import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/tournament/delete_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_all_tournaments_use_case.dart';
import 'package:bracket_helper/presentation/home/home_action.dart';
import 'package:bracket_helper/presentation/home/home_state.dart';
import 'package:flutter/foundation.dart';
import 'package:bracket_helper/domain/use_case/match/get_all_matches_use_case.dart';

class HomeViewModel with ChangeNotifier {
  final List<TournamentModel> _tournaments = [];
  HomeState _state = HomeState();
  HomeState get state => _state;
  final GetAllTournamentsUseCase _getAllTournamentsUseCase;
  final DeleteTournamentUseCase _deleteTournamentUseCase;
  final GetAllMatchesUseCase? _getAllMatchesUseCase;

  List<TournamentModel> get tournaments => _tournaments;

  HomeViewModel({
    required GetAllTournamentsUseCase getAllTournamentsUseCase,
    required DeleteTournamentUseCase deleteTournamentUseCase,
    required GetAllMatchesUseCase? getAllMatchesUseCase,
  }) : _getAllTournamentsUseCase = getAllTournamentsUseCase,
       _deleteTournamentUseCase = deleteTournamentUseCase,
       _getAllMatchesUseCase = getAllMatchesUseCase {
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

  Future<void> printAllMatches() async {
    if (_getAllMatchesUseCase == null) {
      if (kDebugMode) {
        print('getAllMatchesUseCase가 주입되지 않았습니다.');
      }
      return;
    }

    try {
      final result = await _getAllMatchesUseCase.execute();
      if (result.isSuccess) {
        if (kDebugMode) {
          print('모든 매치 정보:');
          for (var match in result.value) {
            print(
              '매치 ID: ${match.id}, 순서: ${match.ord}, 토너먼트ID: ${match.tournamentId}',
            );
            print('플레이어A: ${match.playerA}, 플레이어B: ${match.playerB}');
            print('점수A: ${match.scoreA}, 점수B: ${match.scoreB}');
            if (match.playerC != null || match.playerD != null) {
              print(
                '더블스 매치 - 플레이어C: ${match.playerC}, 플레이어D: ${match.playerD}',
              );
            }
            print('-------------------');
          }
          print('총 ${result.value.length}개의 매치가 있습니다.');
        }
      } else {
        if (kDebugMode) {
          print('매치 정보 불러오기 실패: ${result.error.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('매치 정보 조회 중 오류 발생: $e');
      }
    }
  }

  void onAction(HomeAction action) {
    switch (action) {
      case OnRefresh():
        fetchTournaments();
        break;
      case OnTapHelp():
        printAllMatches();
        break;
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
