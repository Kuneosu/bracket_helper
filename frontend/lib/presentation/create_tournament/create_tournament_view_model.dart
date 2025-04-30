import 'package:bracket_helper/core/utils/date_formatter.dart';
import 'package:bracket_helper/core/utils/bracket_scheduler.dart';
import 'package:bracket_helper/core/utils/single_bracket_scheduler.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/create_match_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/delete_match_by_tournament_id_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class CreateTournamentViewModel with ChangeNotifier {
  final CreateTournamentUseCase _createTournamentUseCase;
  final GetAllGroupsUseCase _getAllGroupsUseCase;
  final GetGroupUseCase _getGroupUseCase;
  final CreateMatchUseCase _createMatchUseCase;
  final DeleteMatchByTournamentIdUseCase _deleteMatchByTournamentIdUseCase;

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
    this._createMatchUseCase,
    this._deleteMatchByTournamentIdUseCase,
  ) {
    fetchAllGroups();
  }

  // 상태 초기화 메서드
  void resetState() {
    debugPrint('CreateTournamentViewModel - 상태 초기화');
    _state = CreateTournamentState(
      tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
    );
    _playerListCache.clear();
    fetchAllGroups();
    _notifyChanges();
  }

  void _notifyChanges() {
    debugPrint('상태 변경: ${_state.tournament.date}');
    debugPrint('현재 선수 목록 수: ${_state.players.length}');
    if (_state.players.isNotEmpty) {
      debugPrint(
        '선수 목록: ${_state.players.map((p) => "${p.id}:${p.name}").join(', ')}',
      );
    }

    // 안전하게 상태 변경 알림
    try {
      // 대부분의 프레임워크 락 이슈는 메인 스레드에서 발생하므로
      // Future.microtask를 사용하여 다음 마이크로태스크 큐에서 실행
      Future.microtask(() => notifyListeners());
    } catch (e) {
      debugPrint('notifyListeners 호출 오류: $e');
    }
  }

  void onAction(CreateTournamentAction action) {
    debugPrint('액션 실행: $action');

    // 액션 타입에 따라 처리
    switch (action) {
      case GenerateMatches():
        debugPrint('GenerateMatches 액션 감지 - 기본 코트 수로 매치 생성');
        _createMatchesDirectly(null);

      case GenerateMatchesWithCourts():
        final courts = action.courts;
        debugPrint('GenerateMatchesWithCourts 액션 감지 - 코트 수: $courts');
        _createMatchesDirectly(courts);

      case ResetState():
        debugPrint('ResetState 액션 감지 - 상태 초기화 시작');
        resetState();

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
        }
      case OnTitleChanged():
        _state = _state.copyWith(
          tournament: _state.tournament.copyWith(title: action.title),
        );
        _notifyChanges();
      case OnGamesPerPlayerChanged():
        try {
          if (action.gamesPerPlayer.isEmpty) return;
          final gamesPerPlayer = int.parse(action.gamesPerPlayer);

          if (gamesPerPlayer < 1) return;

          _state = _state.copyWith(
            tournament: _state.tournament.copyWith(
              gamesPerPlayer: gamesPerPlayer,
            ),
          );
          _notifyChanges();
        } catch (e) {
          debugPrint('게임 수 변환 오류: $e');
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
        debugPrint('[토너먼트 저장 추적] 토너먼트 저장 시작');
        // Future를 반환하지 않고 실행만 함
        // 이 부분이 문제의 원인이었음: 비동기 작업 완료를 기다리지 않고 즉시 다음 화면으로 이동
        saveTournamentAndMatches();
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
        if (action.name.trim().isEmpty) return;

        final newId =
            _state.players.isEmpty
                ? 1
                : _state.players
                        .map((p) => p.id)
                        .reduce((max, id) => id > max ? id : max) +
                    1;

        // 이름 중복 확인 및 처리
        final baseName = action.name.trim();
        String uniqueName = baseName;

        // 동일한 이름을 가진 선수들 찾기
        final duplicateCount =
            _state.players.where((p) {
              // 정확히 같은 이름이거나, "이름(숫자)" 형태인 경우 모두 카운트
              return p.name == baseName ||
                  p.name.startsWith('$baseName(') && p.name.endsWith(')');
            }).length;

        // 중복 선수가 있는 경우
        if (duplicateCount > 0) {
          uniqueName = '$baseName(${duplicateCount + 1})';
          debugPrint('중복된 이름 발견: $baseName → $uniqueName로 변경됨');
        }

        final newPlayer = PlayerModel(id: newId, name: uniqueName);
        _state = _state.copyWith(players: [..._state.players, newPlayer]);
        debugPrint(
          '플레이어 추가 완료: ID ${newPlayer.id}, 이름 ${newPlayer.name} (추가 후 선수 수: ${_state.players.length})',
        );
        _notifyChanges();
      case UpdatePlayer():
        debugPrint(
          '플레이어 수정 시작: ${action.player.id} - ${action.player.name} (현재 선수 수: ${_state.players.length})',
        );

        // 이름 중복 확인 및 처리
        final updatedName = action.player.name.trim();
        
        // 자기 자신을 제외한 나머지 선수들 중에서 동일한 이름 검사
        final isDuplicate = _state.players
            .where((p) => p.id != action.player.id) // 자신을 제외한 선수들
            .any((p) => p.name == updatedName);      // 동일한 이름 확인
        
        if (isDuplicate) {
          debugPrint('선수 수정 실패: 중복된 이름이 존재합니다 - $updatedName');
          // 중복된 이름이 있을 경우 수정 무시
          return;
        }

        // 버그 수정: 특정 ID의 선수만 업데이트하도록 변경
        // 기존 선수 리스트 복사
        final List<PlayerModel> updatedPlayers = List.from(_state.players);

        // 수정할 선수의 인덱스 찾기
        final int playerIndex = updatedPlayers.indexWhere(
          (player) => player.id == action.player.id,
        );

        // 해당 선수가 존재하면 업데이트
        if (playerIndex != -1) {
          updatedPlayers[playerIndex] = action.player;
          _state = _state.copyWith(players: updatedPlayers);
          debugPrint('플레이어 ${action.player.id} 수정 완료: ${action.player.name}');
        } else {
          debugPrint('수정할 플레이어를 찾을 수 없음: ID ${action.player.id}');
        }

        _notifyChanges();
      case RemovePlayer():
        debugPrint(
          '플레이어 삭제 시작: ${action.playerId} (현재 선수 수: ${_state.players.length})',
        );

        // 버그 수정: 삭제 로직 강화
        try {
          // 삭제할 선수의 이름 출력 (디버깅용)
          final playerToRemove = _state.players.firstWhere(
            (player) => player.id == action.playerId,
            orElse: () => PlayerModel(id: -1, name: '알 수 없음'),
          );

          if (playerToRemove.id != -1) {
            debugPrint(
              '삭제할 플레이어: ID ${playerToRemove.id}, 이름 ${playerToRemove.name}',
            );

            // 안전하게 새 리스트 생성 후 특정 ID를 가진 선수만 제외
            final newPlayers =
                _state.players
                    .where((player) => player.id != action.playerId)
                    .toList();

            // 기존 리스트와 새 리스트의 크기 비교로 삭제 확인
            final removed = _state.players.length - newPlayers.length;

            if (removed > 0) {
              _state = _state.copyWith(players: newPlayers);
              debugPrint(
                '플레이어 삭제 완료: ${playerToRemove.name} (삭제 후 선수 수: ${newPlayers.length})',
              );
            } else {
              debugPrint('선수 삭제 실패: ID ${action.playerId}인 선수를 찾을 수 없음');
            }
          } else {
            debugPrint('삭제할 플레이어를 찾을 수 없음: ID ${action.playerId}');
          }
        } catch (e) {
          debugPrint('선수 삭제 중 오류 발생: $e');
        }

        _notifyChanges();
      case FetchAllGroups():
        fetchAllGroups();
      case LoadPlayersFromGroup():
        loadPlayersFromGroup(action.groupId);
      case SelectPlayerFromGroup():
        selectPlayerFromGroup(action.player);
      case OnDiscard():
        _clear();
      case UpdateExistingTournamentMatches():
        debugPrint('[토너먼트 매치 업데이트 추적] 기존 토너먼트 매치 업데이트 시작');
        updateExistingTournamentMatches();
      case SaveTournamentOrUpdateMatches():
        debugPrint('[토너먼트 저장/업데이트 추적] 모드에 따른 저장 로직 시작');
        saveTournamentOrUpdateMatches();
      default:
        // 다른 액션에 대한 기본 처리
        debugPrint('처리되지 않은 액션: $action');
    }
  }

  void _clear() {
    _state = _state.copyWith(
      tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
      players: [],
      matches: [],
      groups: [],
      isEditMode: false, // isEditMode도 초기화하여 편집 모드 상태를 제거
    );
    _playerListCache.clear(); // 캐시도 초기화
    _notifyChanges();
    debugPrint('상태 초기화 완료: 편집 모드 해제');
  }

  Future<void> _saveMatches() async {
    try {
      debugPrint('매치 저장 시작 - ${state.matches.length}개 매치 저장 중...');

      // state.matches가 비어있는 경우 처리
      if (state.matches.isEmpty) {
        debugPrint('저장할 매치가 없습니다.');
        return;
      }

      final tournamentId = _state.tournament.id;
      debugPrint('토너먼트 ID: $tournamentId로 매치 저장');

      // 모든 매치에 대해 비동기 작업 실행
      final futures = <Future<void>>[];

      for (int i = 0; i < state.matches.length; i++) {
        final match = state.matches[i];
        // 토너먼트 ID 설정 확인 및 order 값 설정 (1부터 시작하는 매치 번호)
        final matchOrder = i + 1;
        final saveMatch = match.copyWith(
          tournamentId: tournamentId,
          ord: matchOrder, // 항상 인덱스+1 값으로 설정 (1부터 시작)
        );

        // 매치 저장 전 로깅
        debugPrint(
          '매치 저장 요청: ${i + 1}번째 매치 (토너먼트 ID: $tournamentId, Order: $matchOrder)',
        );

        // Future 리스트에 추가
        futures.add(_saveMatch(saveMatch));
      }

      // 모든 Future가 완료될 때까지 기다림
      await Future.wait(futures);
      debugPrint('모든 매치 저장 작업 완료');

      // 작업 완료 후 상태 갱신
      _notifyChanges();
    } catch (e) {
      debugPrint('매치 저장 오류: $e');
    }
  }

  // 개별 매치 저장을 위한 헬퍼 메서드
  Future<void> _saveMatch(MatchModel match) async {
    try {
      // 로그 추가 - 저장 요청 확인
      debugPrint(
        '매치 저장 요청: ${match.ord}번째 매치 (토너먼트 ID: ${match.tournamentId}, Order: ${match.ord})',
      );

      final result = await _createMatchUseCase.execute(match);
      result.fold(
        onSuccess: (savedMatch) {
          debugPrint('매치 저장 성공: ID ${savedMatch.id}, Order ${savedMatch.ord}');

          // 디버그용: 저장된 매치 정보 상세 출력
          if (kDebugMode) {
            print('저장된 매치 상세 정보:');
            print('  - ID: ${savedMatch.id}');
            print('  - Order: ${savedMatch.ord}');
            print('  - 토너먼트 ID: ${savedMatch.tournamentId}');
            print('  - 선수 A: ${savedMatch.playerA}');
            print('  - 선수 B: ${savedMatch.playerB}');
            print('  - 선수 C: ${savedMatch.playerC}');
            print('  - 선수 D: ${savedMatch.playerD}');
            print('  - 점수 A: ${savedMatch.scoreA}');
            print('  - 점수 B: ${savedMatch.scoreB}');
          }
        },
        onFailure: (error) {
          debugPrint('매치 저장 실패: ${error.message}');
        },
      );
    } catch (e) {
      debugPrint('매치 저장 중 예외 발생: $e');
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

      final result = await _createTournamentUseCase.execute(_state.tournament);

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
    try {
      // Future.microtask를 사용하여 안전하게 알림
      Future.microtask(() => notifyListeners());
    } catch (e) {
      debugPrint('CreateTournamentViewModel - notifyListeners 호출 오류: $e');
    }
  }

  // 특정 그룹의 선수 목록을 조회 (캐시 또는 빈 목록 반환, 비동기 로드는 별도로 호출)
  List<PlayerModel> getPlayersInGroupSync(int groupId) {
    debugPrint('CreateTournamentViewModel - 그룹 $groupId의 선수 목록 캐시 조회');

    // ALL_GROUPS 상수 값이면 모든 그룹의 선수 목록 병합하여 반환
    if (groupId == -999) {
      // -999는 모든 그룹 선택을 의미
      final allPlayers = <PlayerModel>[];
      final seenPlayerIds = <int>{}; // 중복 제거용 집합

      // 모든 그룹의 선수 목록 조회
      for (final groupId in _playerListCache.keys) {
        final players = _playerListCache[groupId] ?? [];

        // 중복 선수 제거
        for (final player in players) {
          if (!seenPlayerIds.contains(player.id)) {
            allPlayers.add(player);
            seenPlayerIds.add(player.id);
          }
        }
      }

      debugPrint(
        'CreateTournamentViewModel - 모든 그룹 선수 목록 반환: ${allPlayers.length}명',
      );
      return allPlayers;
    }

    // 특정 그룹 ID에 대한 처리
    // 캐시된 선수 목록이 있으면 바로 반환
    if (_playerListCache.containsKey(groupId)) {
      final cachedPlayers = _playerListCache[groupId] ?? [];
      debugPrint(
        'CreateTournamentViewModel - 그룹 $groupId의 선수 목록 캐시 있음 (${cachedPlayers.length}명)',
      );
      return cachedPlayers;
    }

    // 캐시에 없으면 빈 목록 반환
    debugPrint('CreateTournamentViewModel - 그룹 $groupId의 선수 목록 캐시 없음, 빈 목록 반환');
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
    try {
      // Future.microtask를 사용하여 안전하게 알림
      Future.microtask(() => notifyListeners());
    } catch (e) {
      debugPrint('CreateTournamentViewModel - notifyListeners 호출 오류: $e');
    }
  }

  // 그룹에서 선수 선택
  void selectPlayerFromGroup(PlayerModel player) {
    debugPrint(
      'CreateTournamentViewModel - 그룹에서 선수 선택: ${player.id} - ${player.name}',
    );

    // 이미 선택된 선수인지 확인 (이름으로만 비교)
    final isAlreadySelected = _state.players.any((p) => p.name == player.name);

    if (isAlreadySelected) {
      debugPrint('CreateTournamentViewModel - 이미 선택된 선수입니다: ${player.name}');
      return;
    }

    // 선수 목록에 추가
    _state = _state.copyWith(players: [..._state.players, player]);

    debugPrint(
      'CreateTournamentViewModel - 선수 추가됨: ${player.name} (현재 ${_state.players.length}명)',
    );

    // 안전하게 상태 변경 알림
    try {
      // Future.microtask를 사용하여 안전하게 알림
      Future.microtask(() => notifyListeners());
    } catch (e) {
      debugPrint('CreateTournamentViewModel - notifyListeners 호출 오류: $e');
    }
  }

  // 상태 강제 갱신 메서드 (UI 업데이트를 위한 용도)
  void refreshState() {
    debugPrint('CreateTournamentViewModel - 상태 강제 갱신');
    try {
      // Future.microtask를 사용하여 안전하게 알림
      Future.microtask(() => notifyListeners());
    } catch (e) {
      debugPrint('CreateTournamentViewModel - 상태 갱신 중 오류: $e');
    }
  }

  // 기존 토너먼트 데이터로 상태 초기화 (대진 수정 시 사용)
  void initializeFromExisting({
    required TournamentModel tournament,
    required List<PlayerModel> players,
    required List<MatchModel> matches,
  }) {
    debugPrint('기존 토너먼트 데이터로 상태 초기화 시작');
    debugPrint('토너먼트 ID: ${tournament.id}, 제목: ${tournament.title}');
    debugPrint('선수 수: ${players.length}, 매치 수: ${matches.length}');

    // 편집 모드에서 각 선수에게 새로운 고유 ID를 부여
    // 이는 위젯 식별용으로만 사용되며, 원본 이름은 유지
    final List<PlayerModel> playersWithUniqueIds = [];
    int nextId = 10000; // 충분히 큰 시작 ID 사용
    
    for (final player in players) {
      // ID를 고유값으로 변경하고 이름은 유지
      playersWithUniqueIds.add(PlayerModel(
        id: nextId++,
        name: player.name,
      ));
      debugPrint('선수 ID 재할당: ${player.name} -> ID: ${nextId-1}');
    }
    
    debugPrint('선수 ID 변환 완료: ${playersWithUniqueIds.length}명의 선수에게 고유 ID 할당됨');

    // 상태 업데이트 (isEditMode를 true로 설정)
    _state = _state.copyWith(
      tournament: tournament,
      players: playersWithUniqueIds,
      matches: matches,
      isEditMode: true, // 대진 수정 모드로 설정
    );

    // 상태 변경 알림
    _notifyChanges();
    debugPrint('기존 토너먼트 데이터로 상태 초기화 완료 (대진 수정 모드)');
  }

  // 모드에 따라 토너먼트 저장 또는 매치 업데이트 (EditMatchScreen에서 호출됨)
  Future<int> saveTournamentOrUpdateMatches() async {
    try {
      // 현재 모드 확인
      if (_state.isEditMode) {
        debugPrint('대진 수정 모드: 기존 토너먼트 매치만 업데이트');
        await updateExistingTournamentMatches();
        return _state.tournament.id; // 기존 토너먼트 ID 반환
      } else {
        debugPrint('새 대진표 생성 모드: 새 토너먼트 및 매치 저장');
        await saveTournamentAndMatches();
        return _state.tournament.id; // 새로 생성된 토너먼트 ID 반환
      }
    } catch (e) {
      debugPrint('토너먼트 저장 또는 매치 업데이트 중 오류 발생: $e');
      rethrow;
    }
  }

  // 직접 매치를 생성하는 함수
  void _createMatchesDirectly([int? customCourts]) {
    debugPrint(
      '_createMatchesDirectly 함수 호출됨${customCourts != null ? " (코트 수: $customCourts)" : ""}',
    );

    try {
      // 선수 목록 확인
      final players = _state.players;
      final isDoubles = _state.tournament.isDoubles;
      final gamesPerPlayer = _state.tournament.gamesPerPlayer;

      debugPrint('토너먼트 타입: ${isDoubles ? "복식" : "단식"}');
      debugPrint('플레이어 당 게임 수: $gamesPerPlayer');

      if (players.length < 4) {
        debugPrint('선수가 부족합니다 (${players.length}명, 최소 4명 필요)');
        return;
      }

      debugPrint('매치 생성 시작 - 선수 ${players.length}명');
      
      // 선수 ID가 바뀌었으므로 이름으로 디버깅 추가
      for (final player in players) {
        debugPrint('매치 생성에 사용될 선수: ID ${player.id}, 이름 ${player.name}');
      }

      List<MatchModel> newMatches;

      try {
        // 코트 수 계산 (단식과 복식에 따라 다르게 계산)
        int courts;
        if (isDoubles) {
          // 복식: 선수 4명당 1코트 (기존 방식)
          courts = customCourts ?? players.length ~/ 4;
          debugPrint('복식 모드 - 사용할 코트 수: $courts');
        } else {
          // 단식: 선수 2명당 1코트
          courts = customCourts ?? players.length ~/ 2;
          debugPrint('단식 모드 - 사용할 코트 수: $courts');
        }

        // 단식/복식에 따라 다른 스케줄러 사용
        if (isDoubles) {
          // 복식 매치 생성
          debugPrint('BracketScheduler 사용하여 복식 매치 생성');
          newMatches = BracketScheduler.generate(
            players.shuffled(),
            gamesPer: gamesPerPlayer,
            courts: courts,
          );
        } else {
          // 단식 매치 생성
          debugPrint('SinglesBracketScheduler 사용하여 단식 매치 생성 (선수: ${players.length}명, 각 선수당 게임 수: $gamesPerPlayer)');
          
          try {
            newMatches = SinglesBracketScheduler.generate(
              players.shuffled(),
              gamesPer: gamesPerPlayer,
              courts: courts,
            );
            
            // 예상 매치 수 계산 및 검증
            final expectedMatches = (players.length * gamesPerPlayer) ~/ 2;
            debugPrint('예상 매치 수: $expectedMatches, 생성된 매치 수: ${newMatches.length}');
            
            if (newMatches.length < expectedMatches) {
              debugPrint('경고: 예상보다 적은 매치가 생성되었습니다. 생성: ${newMatches.length}, 예상: $expectedMatches');
            }
          } catch (e) {
            debugPrint('SinglesBracketScheduler 오류: $e');
            rethrow;
          }
        }

        debugPrint('생성된 매치 수: ${newMatches.length}');

        // 각 매치에 점수 설정 및 ID 수정 (자동 생성 대신 0으로 설정)
        for (int i = 0; i < newMatches.length; i++) {
          final match = newMatches[i];

          // order는 스케줄러가 기본적으로 설정한 값 사용,
          // id를 0으로 설정하여 데이터베이스에서 자동 생성되도록 함
          // scoreA와 scoreB는 0으로 명시적 설정
          newMatches[i] = match.copyWith(
            id: 0, // id를 0으로 설정하여 DB에서 자동 생성되도록 함
            scoreA: 0,
            scoreB: 0,
          );

          // 로그로 생성된 매치 정보 출력
          if (isDoubles) {
            debugPrint(
              'Match #${i + 1}: Order ${match.ord}, ${match.playerA} & ${match.playerC} vs ${match.playerB} & ${match.playerD}',
            );
          } else {
            debugPrint(
              'Match #${i + 1}: Order ${match.ord}, ${match.playerA} vs ${match.playerB}',
            );
          }
        }
      } catch (e) {
        debugPrint('매치 생성 중 오류: $e');
        return;
      }

      // 생성한 매치 저장
      debugPrint('총 ${newMatches.length}개 매치 생성 완료');
      _state = _state.copyWith(matches: newMatches);
      debugPrint('상태 업데이트: matches 길이 = ${_state.matches.length}');
      _notifyChanges();
      debugPrint('상태 변경 알림 완료');
    } catch (e) {
      debugPrint('매치 생성 중 오류: $e');
    }
  }

  // 토너먼트와 매치를 함께 저장하는 비동기 메서드
  Future<void> saveTournamentAndMatches() async {
    try {
      debugPrint('토너먼트 및 매치 저장 시작');
      // 토너먼트 저장 (기존의 _saveTournament 호출)
      await _saveTournament();

      // 매치 저장 (기존의 _saveMatches 호출)
      await _saveMatches();

      debugPrint('토너먼트 및 매치 저장 완료');
    } catch (e) {
      debugPrint('토너먼트 및 매치 저장 중 오류 발생: $e');
    }
  }

  // 기존 토너먼트의 매치만 업데이트하는 메서드 (대진 수정 시 사용)
  Future<void> updateExistingTournamentMatches() async {
    try {
      final tournamentId = _state.tournament.id;

      // 토너먼트 ID가 유효하지 않으면 먼저 저장
      if (tournamentId <= 0) {
        debugPrint('유효하지 않은 토너먼트 ID: $tournamentId, 먼저 토너먼트 저장 후 진행');
        await _saveTournament();

        // 저장 후 ID 재확인
        if (_state.tournament.id <= 0) {
          debugPrint('토너먼트 저장 후에도 ID가 유효하지 않음');
          throw Exception('토너먼트 저장에 실패했습니다.');
        }
      }

      // 저장 후 갱신된 ID 사용
      final updatedTournamentId = _state.tournament.id;
      debugPrint('기존 토너먼트($updatedTournamentId)의 매치 업데이트 시작');

      // 토너먼트 ID로 한 번에 모든 매치 삭제
      debugPrint('토너먼트($updatedTournamentId) 매치 일괄 삭제 시작');
      final deleteResult = await _deleteMatchByTournamentIdUseCase.execute(
        updatedTournamentId,
      );

      if (deleteResult.isSuccess) {
        debugPrint('토너먼트($updatedTournamentId) 매치 일괄 삭제 성공');
      } else {
        debugPrint(
          '토너먼트($updatedTournamentId) 매치 일괄 삭제 실패: ${deleteResult.error.message}',
        );
        // 실패해도 계속 진행 (새 매치 저장은 시도)
      }

      // 2. 새 매치 저장
      debugPrint('새 매치 저장 시작 - 총 ${_state.matches.length}개 매치');
      await _saveMatches();

      debugPrint('기존 토너먼트($updatedTournamentId)의 매치 업데이트 완료');
    } catch (e) {
      debugPrint('기존 토너먼트 매치 업데이트 중 오류 발생: $e');
      rethrow;
    }
  }
}
