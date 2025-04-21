import 'package:bracket_helper/core/utils/date_formatter.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_state.dart';
import 'package:flutter/material.dart';

class CreateTournamentViewModel with ChangeNotifier {
  final CreateTournamentUseCase _createTournamentUseCase;
  final GetAllGroupsUseCase _getAllGroupsUseCase;
  final GetGroupUseCase _getGroupUseCase;

  CreateTournamentState _state = CreateTournamentState(
    tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
  );
  CreateTournamentState get state => _state;

  // 그룹별 선수 목록 캐시
  final Map<int, List<PlayerModel>> _playerListCache = {};

  CreateTournamentViewModel(
    this._createTournamentUseCase,
    this._getAllGroupsUseCase,
    this._getGroupUseCase,
  );

  void _notifyChanges() {
    debugPrint('상태 변경: ${_state.tournament.date}');
    debugPrint('현재 선수 목록 수: ${_state.players.length}');
    if (_state.players.isNotEmpty) {
      debugPrint(
        '선수 목록: ${_state.players.map((p) => "${p.id}:${p.name}").join(', ')}',
      );
    }
    notifyListeners();
  }

  void onAction(CreateTournamentAction action) {
    debugPrint('액션 실행: $action');

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
              tournament: _state.tournament.copyWith(winPoint: score),
            );
          } else if (action.type == '무') {
            _state = _state.copyWith(
              tournament: _state.tournament.copyWith(drawPoint: score),
            );
          } else if (action.type == '패') {
            _state = _state.copyWith(
              tournament: _state.tournament.copyWith(losePoint: score),
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
            title:
                '${DateFormatter.formatToYYYYMMDD(_state.tournament.date)} 대회',
          ),
        );
        _notifyChanges();
      case SaveTournament():
        _saveTournament();
      case UpdateProcess():
        debugPrint('프로세스 업데이트: ${action.process}');
        final updatedTournament = _state.tournament.copyWith(
          process: action.process,
        );
        _state = _state.copyWith(tournament: updatedTournament);
        debugPrint('새 프로세스 값: ${_state.tournament.process}');
        _notifyChanges();
      case AddPlayer():
        debugPrint(
          '플레이어 추가 시작: ${action.name} (현재 선수 수: ${_state.players.length})',
        );
        if (action.name.trim().isEmpty) return; // 빈 이름은 처리하지 않음

        // 임시 ID 생성 (실제 앱에서는 DB 또는 UUID 등으로 대체)
        final newId =
            _state.players.isEmpty
                ? 1
                : _state.players
                        .map((p) => p.id)
                        .reduce((max, id) => id > max ? id : max) +
                    1;

        final newPlayer = PlayerModel(id: newId, name: action.name.trim());
        _state = _state.copyWith(players: [..._state.players, newPlayer]);
        debugPrint(
          '플레이어 추가 완료: ID ${newPlayer.id}, 이름 ${newPlayer.name} (추가 후 선수 수: ${_state.players.length})',
        );
        _notifyChanges();
      case UpdatePlayer():
        debugPrint(
          '플레이어 수정 시작: ${action.player.id} - ${action.player.name} (현재 선수 수: ${_state.players.length})',
        );
        final updatedPlayers =
            _state.players.map((player) {
              if (player.id == action.player.id) {
                return action.player;
              }
              return player;
            }).toList();

        _state = _state.copyWith(players: updatedPlayers);
        debugPrint('플레이어 수정 완료 (수정 후 선수 수: ${_state.players.length})');
        _notifyChanges();
      case RemovePlayer():
        debugPrint(
          '플레이어 삭제 시작: ${action.playerId} (현재 선수 수: ${_state.players.length})',
        );
        _state = _state.copyWith(
          players:
              _state.players
                  .where((player) => player.id != action.playerId)
                  .toList(),
        );
        debugPrint('플레이어 삭제 완료 (삭제 후 선수 수: ${_state.players.length})');
        _notifyChanges();
      case FetchAllGroups():
        fetchAllGroups();
      case LoadPlayersFromGroup():
        loadPlayersFromGroup(action.groupId);
      case SelectPlayerFromGroup():
        selectPlayerFromGroup(action.player);
      case OnDiscard():
        _state = _state.copyWith(
          tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
        );
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

      final params = CreateTournamentParams.fromTournamentModel(
        _state.tournament,
      );
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

  // 모든 그룹 목록 조회
  Future<void> fetchAllGroups() async {
    debugPrint('CreateTournamentViewModel - 모든 그룹 목록 조회 시작');

    // 상태 변경 전 플래그만 설정
    _state = _state.copyWith(isLoading: true);

    // 즉시 notifyListeners 호출하지 않고 비동기 작업 먼저 수행
    try {
      debugPrint('CreateTournamentViewModel - GetAllGroupsUseCase 호출 시작');
      final result = await _getAllGroupsUseCase.execute();
      debugPrint('CreateTournamentViewModel - GetAllGroupsUseCase 호출 완료');

      if (result.isSuccess) {
        // 작업 완료 후 상태 업데이트
        final groups = result.value;
        debugPrint(
          'CreateTournamentViewModel - 그룹 목록 조회 성공: ${groups.length}개 그룹',
        );

        if (groups.isNotEmpty) {
          debugPrint(
            'CreateTournamentViewModel - 그룹 목록: ${groups.map((g) => "${g.id}:${g.name}").join(", ")}',
          );
        }

        _state = _state.copyWith(groups: groups, isLoading: false);
      } else {
        debugPrint(
          'CreateTournamentViewModel - 그룹 목록 조회 실패: ${result.error.message}',
        );
        _state = _state.copyWith(
          errorMessage: '그룹 목록을 불러오는 데 실패했습니다: ${result.error.message}',
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('CreateTournamentViewModel - 그룹 목록 조회 중 예외 발생: $e');
      _state = _state.copyWith(
        errorMessage: '그룹 목록을 불러오는 중 오류가 발생했습니다: $e',
        isLoading: false,
      );
    }

    // 모든 작업 완료 후 한 번만 notifyListeners 호출
    debugPrint('CreateTournamentViewModel - 그룹 목록 조회 완료, UI 갱신 요청');
    notifyListeners();
  }

  // 특정 그룹의 선수 목록을 조회 (캐시 또는 빈 목록 반환, 비동기 로드는 별도로 호출)
  List<PlayerModel> getPlayersInGroupSync(int groupId) {
    // 캐시된 선수 목록이 있으면 바로 반환
    if (_playerListCache.containsKey(groupId)) {
      return _playerListCache[groupId] ?? [];
    }

    // 캐시에 없으면 빈 목록 반환
    return [];
  }

  // 특정 그룹의 선수 목록 조회 (비동기 메서드)
  Future<void> loadPlayersFromGroup(int groupId) async {
    debugPrint('CreateTournamentViewModel - 그룹 $groupId의 선수 목록 조회 시작');

    // UI에서 직접 로딩 상태를 처리하므로 여기서는 상태만 업데이트하고 알림 없음
    _state = _state.copyWith(isLoading: true);

    try {
      // 캐시된 선수 목록이 있는지 확인
      if (_playerListCache.containsKey(groupId)) {
        final cachedPlayers = _playerListCache[groupId]!;
        debugPrint(
          'CreateTournamentViewModel - 캐시에서 선수 목록 반환 (${cachedPlayers.length}명)',
        );

        _state = _state.copyWith(isLoading: false);
        // 캐시 사용 시에도 상태 업데이트만 하고 notifyListeners는 호출하지 않음
        return;
      }

      // 캐시에 없으면 UseCase로 조회
      final result = await _getGroupUseCase.execute(groupId);

      if (result.isSuccess) {
        // DB의 Player 모델을 UI 표시용 PlayerModel로 변환
        final playersFromDb = result.value.players;
        final players =
            playersFromDb
                .map((player) => PlayerModel(id: player.id, name: player.name))
                .toList();

        // 선수 목록 캐시에 저장
        _playerListCache[groupId] = players;

        debugPrint(
          'CreateTournamentViewModel - DB에서 선수 목록 조회 성공 (${players.length}명)',
        );
      } else {
        debugPrint(
          'CreateTournamentViewModel - 그룹 정보 조회 실패: ${result.error.message}',
        );
        _state = _state.copyWith(
          errorMessage: '그룹 선수 목록을 불러오는 데 실패했습니다: ${result.error.message}',
        );
      }
    } catch (e) {
      debugPrint('CreateTournamentViewModel - 그룹 선수 목록 조회 중 예외 발생: $e');
      _state = _state.copyWith(errorMessage: '그룹 선수 목록을 불러오는 중 오류가 발생했습니다: $e');
    }

    _state = _state.copyWith(isLoading: false);

    // 캐시 업데이트 후 UI에 알림 (필요한 경우만)
    notifyListeners();
  }

  // 그룹에서 선수 선택
  void selectPlayerFromGroup(PlayerModel player) {
    debugPrint(
      'CreateTournamentViewModel - 그룹에서 선수 선택: ${player.id} - ${player.name}',
    );

    // 이미 선택된 선수인지 확인
    final isAlreadySelected = _state.players.any((p) => p.id == player.id);

    if (isAlreadySelected) {
      debugPrint('CreateTournamentViewModel - 이미 선택된 선수입니다: ${player.name}');
      return;
    }

    // 선수 목록에 추가
    _state = _state.copyWith(players: [..._state.players, player]);

    debugPrint(
      'CreateTournamentViewModel - 선수 추가됨: ${player.name} (현재 ${_state.players.length}명)',
    );
    notifyListeners();
  }
}
