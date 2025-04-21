import 'package:bracket_helper/core/utils/date_formatter.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_state.dart';
import 'package:flutter/material.dart';

class CreateTournamentViewModel with ChangeNotifier {
  final CreateTournamentUseCase _createTournamentUseCase;
  
  CreateTournamentState _state = CreateTournamentState(
    tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
  );
  CreateTournamentState get state => _state;

  CreateTournamentViewModel(this._createTournamentUseCase);

  void _notifyChanges() {
    debugPrint('상태 변경: ${_state.tournament.date}');
    notifyListeners();
  }

  void onAction(CreateTournamentAction action) {
    switch (action) {
      case OnDateChanged():
        debugPrint('날짜 변경: ${action.date}');
        _state = _state.copyWith(
          tournament: _state.tournament.copyWith(date: action.date),
        );
        _notifyChanges();
      case OnScoreChanged():
        try {
          if (action.score.isEmpty) return; // 빈 값인 경우 처리하지 않음
          final score = int.parse(action.score);
          
          if (action.type == '승') {
            _state = _state.copyWith(
              tournament: _state.tournament.copyWith(
                winPoint: score,
              ),
            );
          } else if (action.type == '무') {
            _state = _state.copyWith(
              tournament: _state.tournament.copyWith(
                drawPoint: score,
              ),
            );
          } else if (action.type == '패') {
            _state = _state.copyWith(
              tournament: _state.tournament.copyWith(
                losePoint: score,
              ),
            );
          }
          _notifyChanges();
        } catch (e) {
          debugPrint('점수 변환 오류: $e');
          // 오류 발생 시 기존 값 유지
        }
      case OnTitleChanged():
        _state = _state.copyWith(
          tournament: _state.tournament.copyWith(title: action.title),
        );
        _notifyChanges();
      case OnGamesPerPlayerChanged():
        try {
          if (action.gamesPerPlayer.isEmpty) return; // 빈 값인 경우 처리하지 않음
          final gamesPerPlayer = int.parse(action.gamesPerPlayer);
          
          if (gamesPerPlayer < 1) return; // 1보다 작은 값은 처리하지 않음
          
          _state = _state.copyWith(
            tournament: _state.tournament.copyWith(
              gamesPerPlayer: gamesPerPlayer,
            ),
          );
          _notifyChanges();
        } catch (e) {
          debugPrint('게임 수 변환 오류: $e');
          // 오류 발생 시 기존 값 유지
        }
      case OnIsDoublesChanged():
        _state = _state.copyWith(
          tournament: _state.tournament.copyWith(isDoubles: action.isDoubles),
        );
        _notifyChanges();
      case OnRecommendTitle():
        _state = _state.copyWith(
          tournament: _state.tournament.copyWith(
            title: '${DateFormatter.formatToYYYYMMDD(_state.tournament.date)} 대회',
          ),
        );
        _notifyChanges();
      case SaveTournament():
        _saveTournament();
      case UpdateProcess():
        debugPrint('프로세스 업데이트: ${action.process}');
        final updatedTournament = _state.tournament.copyWith(process: action.process);
        _state = _state.copyWith(tournament: updatedTournament);
        debugPrint('새 프로세스 값: ${_state.tournament.process}');
        _notifyChanges();
    }
  }

  Future<void> _saveTournament() async {
    try {
      // 타이틀이 비어있는 경우 자동으로 날짜를 사용하여 설정
      String title = _state.tournament.title;
      if (title.isEmpty) {
        title = '${DateFormatter.formatToYYYYMMDD(_state.tournament.date)} 대회';
        _state = _state.copyWith(
          tournament: _state.tournament.copyWith(title: title),
        );
      }

      final params = CreateTournamentParams.fromTournamentModel(_state.tournament);
      final result = await _createTournamentUseCase.execute(params);

      result.fold(
        onSuccess: (id) {
          debugPrint('토너먼트 저장 성공: ID $id');
          // 생성된 ID로 상태 업데이트
          _state = _state.copyWith(
            tournament: _state.tournament.copyWith(id: id),
          );
          _notifyChanges();
        },
        onFailure: (error) {
          debugPrint('토너먼트 저장 실패: ${error.message}');
          // 에러 처리를 추가할 수 있음
        },
      );
    } catch (e) {
      debugPrint('_saveTournament 예외 발생: $e');
    }
  }
}
