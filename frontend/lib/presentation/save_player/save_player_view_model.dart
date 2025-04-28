import 'package:bracket_helper/domain/use_case/group/add_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/delete_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/count_players_in_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/update_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/add_player_to_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/remove_player_from_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/delete_player_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/update_player_use_case.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/save_player_state.dart';
import 'package:flutter/material.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';

class SavePlayerViewModel with ChangeNotifier {
  SavePlayerState _state = SavePlayerState();
  SavePlayerState get state => _state;

  // UseCase들 주입
  final GetAllGroupsUseCase _getAllGroupsUseCase;
  final AddGroupUseCase _addGroupUseCase;
  final CountPlayersInGroupUseCase _countPlayersInGroupUseCase;
  final DeleteGroupUseCase _deleteGroupUseCase;
  final UpdateGroupUseCase _updateGroupUseCase;
  final GetGroupUseCase _getGroupUseCase;
  final AddPlayerToGroupUseCase _addPlayerToGroupUseCase;
  final RemovePlayerFromGroupUseCase _removePlayerFromGroupUseCase;
  final DeletePlayerUseCase _deletePlayerUseCase;
  final UpdatePlayerUseCase _updatePlayerUseCase;

  // 그룹별 선수 수 캐시
  final Map<int, int> _playerCountCache = {};

  // 그룹별 선수 목록 캐시
  final Map<int, List<PlayerModel>> _playerListCache = {};

  SavePlayerViewModel({
    required GetAllGroupsUseCase getAllGroupsUseCase,
    required AddGroupUseCase addGroupUseCase,
    required CountPlayersInGroupUseCase countPlayersInGroupUseCase,
    required DeleteGroupUseCase deleteGroupUseCase,
    required UpdateGroupUseCase updateGroupUseCase,
    required GetGroupUseCase getGroupUseCase,
    required AddPlayerToGroupUseCase addPlayerToGroupUseCase,
    required RemovePlayerFromGroupUseCase removePlayerFromGroupUseCase,
    required DeletePlayerUseCase deletePlayerUseCase,
    required UpdatePlayerUseCase updatePlayerUseCase,
  }) : _getAllGroupsUseCase = getAllGroupsUseCase,
       _addGroupUseCase = addGroupUseCase,
       _countPlayersInGroupUseCase = countPlayersInGroupUseCase,
       _deleteGroupUseCase = deleteGroupUseCase,
       _updateGroupUseCase = updateGroupUseCase,
       _getGroupUseCase = getGroupUseCase,
       _addPlayerToGroupUseCase = addPlayerToGroupUseCase,
       _removePlayerFromGroupUseCase = removePlayerFromGroupUseCase,
       _deletePlayerUseCase = deletePlayerUseCase,
       _updatePlayerUseCase = updatePlayerUseCase {
    fetchAllGroups();
  }

  Future<void> fetchAllGroups() async {
    // 현재 선택된 그룹 ID 저장
    final currentSelectedGroupId = _state.selectedGroupId;
    
    debugPrint('fetchAllGroups 시작: 현재 선택된 그룹 ID=$currentSelectedGroupId, 현재 그룹 수=${_state.groups.length}');

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final result = await _getAllGroupsUseCase.execute();
      if (result.isSuccess) {
        final newGroups = result.value;
        // 선택된 그룹 ID를 유지하며 그룹 목록 업데이트
        _state = _state.copyWith(
          groups: newGroups,
          selectedGroupId: currentSelectedGroupId,
        );
        
        debugPrint(
          'fetchAllGroups 성공: ${newGroups.length}개 그룹 로드, 선택된 그룹 ID 유지: $currentSelectedGroupId',
        );
        
        if (newGroups.isNotEmpty) {
          debugPrint(
            '그룹 목록: ${newGroups.map((g) => "${g.id}:${g.name}").join(", ")}',
          );
        }

        // 그룹 목록을 불러온 후 각 그룹별 선수 수 조회 및 캐시 업데이트
        await _updatePlayerCounts();
      } else {
        debugPrint('fetchAllGroups 실패: ${result.error.message}');
        _state = _state.copyWith(errorMessage: result.error.message);
      }
    } catch (e) {
      debugPrint('fetchAllGroups 중 예외 발생: $e');
      _state = _state.copyWith(errorMessage: '그룹 목록을 가져오는 중 오류가 발생했습니다: $e');
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  // 그룹별 선수 수 조회 및 캐시 업데이트 (내부 메서드)
  Future<void> _updatePlayerCounts() async {
    debugPrint('그룹별 선수 수 조회 시작 (${_state.groups.length}개 그룹)');

    for (final group in _state.groups) {
      try {
        final result = await _countPlayersInGroupUseCase.execute(group.id);
        if (result.isSuccess) {
          _playerCountCache[group.id] = result.value;
          debugPrint('그룹 ${group.id}(${group.name}): 선수 ${result.value}명');
        }
      } catch (e) {
        debugPrint('그룹 ${group.id} 선수 수 조회 실패: $e');
      }
    }

    debugPrint('그룹별 선수 수 조회 완료: ${_playerCountCache.length}개 그룹 업데이트됨');
  }

  void onAction(SavePlayerAction action) async {
    switch (action) {
      case OnGroupNameChanged(name: final name):
        updateGroupNameValidity(name.trim().isNotEmpty);
        break;

      case OnGroupColorSelected(color: final color):
        updateSelectedGroupColor(color);
        break;

      case OnSaveGroup(name: final name, color: final color):
        await saveGroup(name: name, color: color);
        break;

      case OnDeleteGroup(groupId: final groupId):
        await deleteGroup(groupId);
        break;

      case OnUpdateGroup(
        groupId: final groupId,
        newName: final newName,
        newColor: final newColor,
      ):
        await updateGroup(
          groupId: groupId,
          newName: newName,
          newColor: newColor,
        );
        break;

      case OnPlayerNameChanged(name: final name):
        updatePlayerNameValidity(name.trim().isNotEmpty);
        break;

      case OnSavePlayer(name: final name, groupId: final groupId):
        await addPlayerToGroup(name: name, groupId: groupId);
        break;

      case OnSaveMultiplePlayers(names: final names, groupId: final groupId):
        await addMultiplePlayersToGroup(names: names, groupId: groupId);
        break;

      case OnDeletePlayer(playerId: final playerId, groupId: final groupId):
        await deletePlayer(playerId: playerId, groupId: groupId);
        break;

      case OnUpdatePlayer(playerId: final playerId, newName: final newName):
        await updatePlayer(playerId: playerId, newName: newName);
        break;

      case OnMovePlayerToGroup():
        // TODO: 플레이어 그룹 이동 로직 구현
        break;

      case OnSearchQueryChanged(query: final query):
        updateSearchQuery(query);
        // 검색어가 변경되면 선수 이름으로도 검색 수행
        if (query.isNotEmpty) {
          await searchByPlayerName(query);
        } else {
          // 검색어가 비었을 때는 선수 이름 검색 결과 초기화
          clearPlayerNameSearchResults();
        }
        break;

      case OnSearchByPlayerName(query: final query):
        await searchByPlayerName(query);
        break;

      case OnToggleGridView():
        toggleGridView();
        break;

      case OnRefresh():
        await refreshAllData();
        break;
      case OnToggleEditMode():
        toggleEditMode();
        break;

      case OnSelectGroup(groupId: final groupId):
        selectGroup(groupId);
        break;
    }
  }

  void updateGroupNameValidity(bool isValid) {
    if (_state.isGroupNameValid != isValid) {
      _state = _state.copyWith(isGroupNameValid: isValid);
      notifyListeners();
    }
  }

  void updateSelectedGroupColor(Color color) {
    final colorValue = color.toARGB32();
    if (_state.selectedGroupColor != colorValue) {
      _state = _state.copyWith(selectedGroupColor: colorValue);
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    if (_state.searchQuery != query) {
      _state = _state.copyWith(searchQuery: query);
      notifyListeners();
      debugPrint(
        '검색어 업데이트: "$query", 필터링된 그룹 수: ${_state.filteredGroups.length}',
      );
    }
  }

  void toggleGridView() {
    final newValue = !_state.isGridView;
    debugPrint('토글 그리드 뷰: $newValue (이전: ${_state.isGridView})');
    _state = _state.copyWith(isGridView: newValue);
    debugPrint('상태 업데이트 후: ${_state.isGridView}');
    notifyListeners();
  }

  void toggleEditMode() {
    debugPrint('토글 편집 모드: ${_state.isEditMode} -> ${!_state.isEditMode}');
    final newEditMode = !_state.isEditMode;

    // 편집 모드로 전환되는 경우, 강제로 리스트뷰로 설정
    if (newEditMode && _state.isGridView) {
      debugPrint('편집 모드로 전환: 그리드뷰에서 리스트뷰로 변경');
      _state = _state.copyWith(isEditMode: newEditMode, isGridView: false);
    } else {
      _state = _state.copyWith(isEditMode: newEditMode);
    }

    notifyListeners();
  }

  Future<void> saveGroup({required String name, required Color color}) async {
    if (name.isEmpty) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    debugPrint('SavePlayerViewModel - 그룹 저장 시작: 이름=$name, 색상=$color');

    try {
      // AddGroupUseCase 호출
      final result = await _addGroupUseCase.execute(
        groupName: name,
        colorValue: color.toARGB32(),
      );
  
      if (result.isSuccess) {
        final newGroup = result.value;
        debugPrint('SavePlayerViewModel - 그룹 저장 성공: ID=${newGroup.id}, 이름=${newGroup.name}');
        
        // 그룹 추가 후 캐시 초기화
        invalidateAllCaches();
        
        // 검색어가 있는 경우 검색 관련 상태 초기화 (새 그룹을 볼 수 있도록)
        if (_state.searchQuery.isNotEmpty) {
          debugPrint('SavePlayerViewModel - 검색어가 있어 검색 상태 초기화');
          _state = _state.copyWith(
            searchQuery: '',
            playerSearchMatchedGroupIds: [],
            matchedPlayerNamesByGroup: {},
          );
        }
        
        // 새로 생성된 그룹을 현재 그룹 목록에 직접 추가 (UI 즉시 갱신을 위해)
        final updatedGroups = [..._state.groups, newGroup];
        debugPrint('SavePlayerViewModel - 새 그룹 추가 후 그룹 수: ${updatedGroups.length}');
        
        // 상태 업데이트 및 UI 갱신
        _state = _state.copyWith(
          groups: updatedGroups,
          isLoading: false,
        );
        notifyListeners();
        
        // DB에서 전체 그룹 목록 다시 로드 (화면 이동 시 최신 데이터 보장)
        // 별도 비동기 호출로 처리하여 UI 블로킹 방지
        _loadLatestGroups();
      } else {
        // 에러 처리
        debugPrint('SavePlayerViewModel - 그룹 저장 실패: ${result.error.message}');
        _state = _state.copyWith(
          errorMessage: '그룹 저장에 실패했습니다: ${result.error.message}',
          isLoading: false,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('SavePlayerViewModel - 그룹 저장 중 예외 발생: $e');
      _state = _state.copyWith(
        errorMessage: '그룹 저장 중 오류가 발생했습니다: $e',
        isLoading: false,
      );
      notifyListeners();
    }
  }
  
  // 그룹 목록을 최신으로 갱신하는 별도 메서드 (백그라운드 실행)
  Future<void> _loadLatestGroups() async {
    try {
      debugPrint('SavePlayerViewModel - _loadLatestGroups: 백그라운드에서 그룹 목록 갱신 시작');
      
      // DB에서 최신 그룹 데이터 로드
      final result = await _getAllGroupsUseCase.execute();
      if (!result.isSuccess) {
        debugPrint('SavePlayerViewModel - 그룹 목록 갱신 실패: ${result.error.message}');
        return;
      }
      
      final latestGroups = result.value;
      debugPrint('SavePlayerViewModel - 최신 그룹 목록 로드 완료: ${latestGroups.length}개');
      
      // 현재 선택된 그룹 ID 저장
      final currentSelectedGroupId = _state.selectedGroupId;
      
      // 상태 업데이트 및 UI 갱신
      _state = _state.copyWith(
        groups: latestGroups,
        selectedGroupId: currentSelectedGroupId,
      );
      
      // 선수 수 캐시 업데이트
      await _updatePlayerCounts();
      
      // UI 갱신
      notifyListeners();
      debugPrint('SavePlayerViewModel - _loadLatestGroups: 그룹 목록 갱신 및 UI 업데이트 완료');
    } catch (e) {
      debugPrint('SavePlayerViewModel - _loadLatestGroups 예외 발생: $e');
    }
  }

  // 그룹 내 선수 수 조회 (캐시 데이터만 사용하는 동기 메서드)
  int getPlayerCountSync(int groupId) {
    // 캐시에 있으면 캐시된 값 반환, 없으면 0 반환
    return _playerCountCache[groupId] ?? 0;
  }

  // 그룹 내 선수 수 조회 (비동기 메서드) - 캐시 업데이트 용도
  Future<int> fetchPlayerCount(int groupId) async {
    // 캐시에 없으면 UseCase로 조회
    final result = await _countPlayersInGroupUseCase.execute(groupId);

    if (result.isSuccess) {
      // 결과를 캐시에 저장
      _playerCountCache[groupId] = result.value;
      return result.value;
    } else {
      debugPrint('선수 수 조회 실패: ${result.error.message}');
      return 0; // 실패 시 기본값 0 반환
    }
  }

  // 모든 그룹의 선수 수 캐시 갱신
  Future<void> refreshPlayerCounts() async {
    debugPrint(
      'SavePlayerViewModel - 모든 그룹의 선수 수 갱신 시작 (${_state.groups.length}개 그룹)',
    );
    int updatedCount = 0;

    for (final group in _state.groups) {
      try {
        final result = await _countPlayersInGroupUseCase.execute(group.id);
        if (result.isSuccess) {
          _playerCountCache[group.id] = result.value;
          updatedCount++;
          debugPrint(
            'SavePlayerViewModel - 그룹 ${group.id}(${group.name}): 선수 ${result.value}명',
          );
        } else {
          debugPrint(
            'SavePlayerViewModel - 그룹 ${group.id} 선수 수 조회 실패: ${result.error.message}',
          );
        }
      } catch (e) {
        debugPrint('SavePlayerViewModel - 그룹 ${group.id} 선수 수 갱신 예외: $e');
      }
    }

    debugPrint('SavePlayerViewModel - 선수 수 갱신 완료: 총 $updatedCount개 그룹');

    // UI 갱신
    notifyListeners();
  }

  // 그룹 선택 메서드
  void selectGroup(int groupId) {
    if (_state.selectedGroupId != groupId) {
      _state = _state.copyWith(selectedGroupId: groupId);
      notifyListeners();
      debugPrint('그룹 선택: $groupId');
    }
  }

  // 특정 그룹의 선수 수 캐시 초기화 (갱신을 위해)
  void invalidatePlayerCount(int groupId) {
    _playerCountCache.remove(groupId);
  }

  // 특정 ID의 그룹 정보 조회
  Future<GroupModel?> getGroupById(int groupId) async {
    if (groupId <= 0) return null;

    debugPrint('SavePlayerViewModel - getGroupById($groupId) 호출됨');

    try {
      // 현재 state에서 해당 ID의 그룹 찾기
      final existingGroup =
          _state.groups.where((g) => g.id == groupId).toList();
      if (existingGroup.isNotEmpty) {
        debugPrint(
          'SavePlayerViewModel - 캐시에서 그룹 찾음: ${existingGroup.first.name}',
        );
        return existingGroup.first;
      }

      // 그룹이 없으면 전체 목록 다시 조회 (UI 갱신 없이)
      debugPrint('SavePlayerViewModel - 캐시에 그룹이 없어 전체 목록 조회 시작');
      await _loadGroupsWithoutNotifying();

      // 다시 조회 후 그룹 찾기
      final group = _state.groups.where((g) => g.id == groupId).toList();
      if (group.isNotEmpty) {
        debugPrint('SavePlayerViewModel - 새로고침 후 그룹 찾음: ${group.first.name}');
        return group.first;
      }

      debugPrint('SavePlayerViewModel - 그룹을 찾을 수 없음: $groupId');
      return null;
    } catch (e) {
      debugPrint('SavePlayerViewModel - getGroupById 예외 발생: $e');
      return null;
    }
  }

  // UI 갱신 없이 그룹 목록 로드 (내부용)
  Future<void> _loadGroupsWithoutNotifying() async {
    debugPrint('SavePlayerViewModel - UI 갱신 없이 그룹 목록 로드');

    try {
      final result = await _getAllGroupsUseCase.execute();
      if (result.isSuccess) {
        // 현재 선택된 그룹 ID 유지
        final currentSelectedGroupId = _state.selectedGroupId;
        _state = _state.copyWith(
          groups: result.value,
          selectedGroupId: currentSelectedGroupId,
        );
        // notifyListeners() 호출하지 않음
        debugPrint(
          'SavePlayerViewModel - 그룹 목록 업데이트됨 (${result.value.length}개), UI 갱신 없음',
        );
      } else {
        debugPrint(
          'SavePlayerViewModel - 그룹 목록 로드 실패: ${result.error.message}',
        );
      }
    } catch (e) {
      debugPrint('SavePlayerViewModel - _loadGroupsWithoutNotifying 예외 발생: $e');
    }
  }

  // 특정 그룹의 선수 목록 조회
  Future<List<PlayerModel>> getPlayersInGroup(int groupId) async {
    debugPrint('SavePlayerViewModel - getPlayersInGroup($groupId) 호출됨');

    try {
      // 캐시된 선수 목록이 있는지 확인
      if (_playerListCache.containsKey(groupId)) {
        final cachedPlayers = _playerListCache[groupId]!;
        debugPrint(
          'SavePlayerViewModel - 캐시에서 선수 목록 반환 (${cachedPlayers.length}명)',
        );
        return cachedPlayers;
      }

      // 사용자 정의 UseCase를 이용해 DB에서 그룹 정보 및 소속 선수 목록 조회
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

        // 선수 수 캐시도 함께 업데이트
        _playerCountCache[groupId] = players.length;

        debugPrint(
          'SavePlayerViewModel - DB에서 선수 목록 조회 성공 (${players.length}명)',
        );
        return players;
      } else {
        debugPrint(
          'SavePlayerViewModel - 그룹 정보 조회 실패: ${result.error.message}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('SavePlayerViewModel - getPlayersInGroup 예외 발생: $e');
      return [];
    }
  }

  // 선수 목록 캐시 초기화 (그룹 정보 변경 시 호출)
  void invalidatePlayerListCache(int groupId) {
    _playerListCache.remove(groupId);
    _playerCountCache.remove(groupId);
    debugPrint('SavePlayerViewModel - 그룹 $groupId의 선수 목록 캐시 초기화됨');
  }

  // 모든 캐시 초기화 (전체 새로고침 시 호출)
  void invalidateAllCaches() {
    _playerListCache.clear();
    _playerCountCache.clear();
    debugPrint('SavePlayerViewModel - 모든 캐시 초기화됨');
  }

  // 그룹 정보 업데이트 (이름 또는 색상)
  Future<void> updateGroup({
    required int groupId,
    String? newName,
    Color? newColor,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    // 디버그 로그
    debugPrint('그룹 정보 업데이트 시도: $groupId => 이름: $newName, 색상: $newColor');

    // UpdateGroupUseCase 호출하여 그룹 정보 변경
    final result = await _updateGroupUseCase.execute(
      groupId: groupId,
      newName: newName,
      newColor: newColor,
    );

    if (result.isSuccess) {
      debugPrint('그룹 정보 업데이트 성공: $groupId');
      // 그룹 관련 캐시 초기화
      invalidatePlayerListCache(groupId);
      // 변경 성공 시 목록 갱신
      await fetchAllGroups();
    } else {
      // 에러 처리
      debugPrint('그룹 정보 업데이트 실패: ${result.error.message}');
      _state = _state.copyWith(
        errorMessage: '그룹 정보를 변경하는 중 오류가 발생했습니다: ${result.error.message}',
      );
    }

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  // 그룹 삭제
  Future<void> deleteGroup(int groupId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    debugPrint('그룹 삭제 시도: $groupId');
    final result = await _deleteGroupUseCase.execute(groupId);

    if (result.isSuccess) {
      debugPrint('그룹 삭제 성공: $groupId');
      // 그룹 관련 캐시 초기화
      invalidatePlayerListCache(groupId);
      // 그룹 목록 새로고침
      await fetchAllGroups();
    } else {
      debugPrint('그룹 삭제 실패: ${result.error.message}');
      _state = _state.copyWith(
        errorMessage: '그룹을 삭제하는 중 오류가 발생했습니다: ${result.error.message}',
      );
    }

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  // 그룹 목록 새로고침 및 모든 캐시 갱신
  Future<void> refreshAllData() async {
    debugPrint('SavePlayerViewModel - 모든 데이터 새로고침 시작');

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // 캐시 초기화
      invalidateAllCaches();
  
      // 그룹 목록 새로고침
      await fetchAllGroups();
  
      debugPrint('SavePlayerViewModel - 모든 데이터 새로고침 완료');
    } catch (e) {
      debugPrint('SavePlayerViewModel - 데이터 새로고침 중 오류 발생: $e');
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  // 그룹에 선수 추가하기
  Future<void> addPlayerToGroup({
    required String name,
    required int groupId,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    if (name.trim().isEmpty) {
      _state = _state.copyWith(errorMessage: '선수 이름을 입력해주세요', isLoading: false);
      notifyListeners();
      return;
    }

    debugPrint('SavePlayerViewModel - 선수 추가 시도: 이름=$name, 그룹ID=$groupId');

    try {
      // 먼저 현재 그룹의 선수 목록을 가져와서 이름 중복 확인
      List<PlayerModel> currentPlayers = [];
      if (_playerListCache.containsKey(groupId)) {
        currentPlayers = _playerListCache[groupId]!;
      } else {
        // 캐시에 없으면 DB에서 조회
        final result = await _getGroupUseCase.execute(groupId);
        if (result.isSuccess) {
          currentPlayers = result.value.players
              .map((player) => PlayerModel(id: player.id, name: player.name))
              .toList();
        }
      }

      // 동일한 이름의 선수 확인
      final baseName = name.trim();
      String uniqueName = baseName;
      
      // 동일한 이름이거나 "이름 2", "이름 3" 패턴의 선수 찾기
      final samePlayers = currentPlayers.where((player) =>
          player.name == baseName ||
          (player.name.startsWith(baseName) && 
           RegExp(r'^$baseName \d+$').hasMatch(player.name))).toList();
      
      if (samePlayers.isNotEmpty) {
        // 중복된 이름이 있으면 숫자 붙이기
        uniqueName = '$baseName ${samePlayers.length + 1}';
        debugPrint('SavePlayerViewModel - 중복된 이름 발견: $baseName → $uniqueName로 변경됨');
      }

      // 수정된 이름으로 AddPlayerToGroupUseCase 호출
      final params = AddPlayerToGroupParams(
        playerName: uniqueName,
        groupId: groupId,
      );

      final result = await _addPlayerToGroupUseCase.execute(params);

      // 결과 처리
      if (result is int) {
        // 성공 (반환값이 선수 ID)
        debugPrint('SavePlayerViewModel - 선수 추가 성공: ID=$result');

        // 해당 그룹의 선수 목록 캐시 초기화
        invalidatePlayerListCache(groupId);

        // 선수 수 캐시도 초기화
        invalidatePlayerCount(groupId);

        // 해당 그룹의 선수 수 다시 조회 (UI 업데이트를 위해)
        await fetchPlayerCount(groupId);

        // 추가한 선수가 속한 그룹이 현재 선택된 그룹인 경우,
        // 자동으로 선수 목록을 갱신해 UI에 반영되도록 함
        if (_state.selectedGroupId == groupId) {
          debugPrint('SavePlayerViewModel - 현재 선택된 그룹에 선수 추가됨, 데이터 갱신');
          // 선수 목록을 미리 불러와 캐시에 저장 (UI는 갱신되지 않음)
          await getPlayersInGroup(groupId);
        }
      } else {
        // 실패 (반환값이 에러 메시지)
        debugPrint('SavePlayerViewModel - 선수 추가 실패: $result');
        _state = _state.copyWith(errorMessage: result.toString());
      }
    } catch (e) {
      debugPrint('SavePlayerViewModel - 선수 추가 중 예외 발생: $e');
      _state = _state.copyWith(errorMessage: '선수 추가 중 오류가 발생했습니다: $e');
    }

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  void updatePlayerNameValidity(bool isValid) {
    if (_state.isPlayerNameValid != isValid) {
      _state = _state.copyWith(isPlayerNameValid: isValid);
      notifyListeners();
    }
  }

  // 선수 삭제 처리
  Future<void> deletePlayer({
    required int playerId,
    required int groupId,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    debugPrint('SavePlayerViewModel - 선수 삭제 시도: ID=$playerId, 그룹ID=$groupId');

    try {
      // 1. 그룹에서 선수 제거
      final removeResult = await _removePlayerFromGroupUseCase.execute(
        playerId,
        groupId,
      );

      if (removeResult.isFailure) {
        debugPrint(
          'SavePlayerViewModel - 그룹에서 선수 제거 실패: ${removeResult.error.message}',
        );
        _state = _state.copyWith(
          errorMessage: '선수를 그룹에서 제거하지 못했습니다: ${removeResult.error.message}',
        );
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return;
      }

      debugPrint('SavePlayerViewModel - 그룹에서 선수 제거 성공');

      // 2. 선수 삭제
      final deleteResult = await _deletePlayerUseCase.execute(playerId);

      if (deleteResult.isFailure) {
        debugPrint(
          'SavePlayerViewModel - 선수 삭제 실패: ${deleteResult.error.message}',
        );
        _state = _state.copyWith(
          errorMessage: '선수를 삭제하지 못했습니다: ${deleteResult.error.message}',
        );
      } else {
        debugPrint('SavePlayerViewModel - 선수 삭제 성공');

        // 해당 그룹의 캐시 초기화
        invalidatePlayerListCache(groupId);
        invalidatePlayerCount(groupId);

        // 해당 그룹의 선수 수 다시 조회 (UI 업데이트를 위해)
        await fetchPlayerCount(groupId);

        // 현재 선택된 그룹이면 선수 목록 미리 로드
        if (_state.selectedGroupId == groupId) {
          debugPrint('SavePlayerViewModel - 선택된 그룹의 선수 삭제, 데이터 갱신');
          await getPlayersInGroup(groupId);
        }
      }
    } catch (e) {
      debugPrint('SavePlayerViewModel - 선수 삭제 중 예외 발생: $e');
      _state = _state.copyWith(errorMessage: '선수 삭제 중 오류가 발생했습니다: $e');
    }

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  // 선수 정보 업데이트 처리
  Future<void> updatePlayer({
    required int playerId,
    required String newName,
  }) async {
    if (newName.trim().isEmpty) {
      _state = _state.copyWith(errorMessage: '선수 이름을 입력해주세요');
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    debugPrint(
      'SavePlayerViewModel - 선수 정보 업데이트 시도: ID=$playerId, 새 이름=$newName',
    );

    try {
      // UpdatePlayerUseCase 호출
      final result = await _updatePlayerUseCase.execute(
        playerId: playerId,
        name: newName.trim(),
      );

      if (result.isSuccess) {
        debugPrint('SavePlayerViewModel - 선수 정보 업데이트 성공: ${result.value}');

        // 모든 그룹의 선수 목록 캐시 초기화 (어떤 그룹에 속해있는지 모르기 때문)
        invalidateAllCaches();

        // 현재 선택된 그룹의 선수 목록 다시 로드
        final selectedGroupId = _state.selectedGroupId;
        if (selectedGroupId != null && selectedGroupId > 0) {
          await getPlayersInGroup(selectedGroupId);
        }
      } else {
        debugPrint(
          'SavePlayerViewModel - 선수 정보 업데이트 실패: ${result.error.message}',
        );
        _state = _state.copyWith(
          errorMessage: '선수 정보 업데이트에 실패했습니다: ${result.error.message}',
        );
      }
    } catch (e) {
      debugPrint('SavePlayerViewModel - 선수 정보 업데이트 중 예외 발생: $e');
      _state = _state.copyWith(errorMessage: '선수 정보 업데이트 중 오류가 발생했습니다: $e');
    }

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  // 여러 선수를 한 번에 추가하는 메서드
  Future<void> addMultiplePlayersToGroup({
    required String names,
    required int groupId,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final namesList = names.split(' ')
        .where((name) => name.trim().isNotEmpty)
        .toList();
    
    if (namesList.isEmpty) {
      _state = _state.copyWith(errorMessage: '선수 이름을 입력해주세요', isLoading: false);
      notifyListeners();
      return;
    }

    debugPrint('SavePlayerViewModel - 다중 선수 추가 시도: ${namesList.length}명, 그룹ID=$groupId');

    // 먼저 현재 그룹의 선수 목록을 가져와서 이름 중복 확인
    List<PlayerModel> currentPlayers = [];
    try {
      if (_playerListCache.containsKey(groupId)) {
        currentPlayers = _playerListCache[groupId]!;
      } else {
        // 캐시에 없으면 DB에서 조회
        final result = await _getGroupUseCase.execute(groupId);
        if (result.isSuccess) {
          currentPlayers = result.value.players
              .map((player) => PlayerModel(id: player.id, name: player.name))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('SavePlayerViewModel - 선수 목록 조회 중 예외 발생: $e');
    }

    int successCount = 0;
    List<String> failedNames = [];

    try {
      // 이미 추가된 선수 이름 목록 (새로 추가되는 선수도 포함하여 갱신)
      List<String> existingNames = currentPlayers.map((p) => p.name).toList();

      for (final name in namesList) {
        final baseName = name.trim();
        String uniqueName = baseName;
        
        // 동일한 이름의 선수 확인 (이미 있는 선수 + 이 배치에서 추가된 선수)
        final sameNameCount = existingNames.where((existingName) =>
            existingName == baseName ||
            (existingName.startsWith(baseName) && 
             RegExp(r'^$baseName \d+$').hasMatch(existingName))).length;
        
        if (sameNameCount > 0) {
          // 중복된 이름이 있으면 숫자 붙이기
          uniqueName = '$baseName ${sameNameCount + 1}';
          debugPrint('SavePlayerViewModel - 중복된 이름 발견: $baseName → $uniqueName로 변경됨');
        }
        
        // 이름 목록에 추가 (다음 반복에서 중복 체크용)
        existingNames.add(uniqueName);

        // AddPlayerToGroupUseCase 호출
        final params = AddPlayerToGroupParams(
          playerName: uniqueName,
          groupId: groupId,
        );

        final result = await _addPlayerToGroupUseCase.execute(params);

        // 결과 처리
        if (result is int) {
          // 성공 (반환값이 선수 ID)
          debugPrint('SavePlayerViewModel - 선수 추가 성공: 이름=$uniqueName, ID=$result');
          successCount++;
        } else {
          // 실패 (반환값이 에러 메시지)
          debugPrint('SavePlayerViewModel - 선수 추가 실패: 이름=$uniqueName, $result');
          failedNames.add(uniqueName);
        }
      }

      // 해당 그룹의 선수 목록 캐시 초기화
      invalidatePlayerListCache(groupId);

      // 선수 수 캐시도 초기화
      invalidatePlayerCount(groupId);

      // 해당 그룹의 선수 수 다시 조회 (UI 업데이트를 위해)
      await fetchPlayerCount(groupId);

      // 추가한 선수가 속한 그룹이 현재 선택된 그룹인 경우,
      // 자동으로 선수 목록을 갱신해 UI에 반영되도록 함
      if (_state.selectedGroupId == groupId) {
        debugPrint('SavePlayerViewModel - 현재 선택된 그룹에 선수 추가됨, 데이터 갱신');
        // 선수 목록을 미리 불러와 캐시에 저장 (UI는 갱신되지 않음)
        await getPlayersInGroup(groupId);
      }

      // 결과 메시지 생성
      if (failedNames.isNotEmpty) {
        _state = _state.copyWith(
          errorMessage: '$successCount명의 선수가 추가되었으나, ${failedNames.length}명 추가 실패: ${failedNames.join(', ')}',
        );
      } else {
        debugPrint('SavePlayerViewModel - 모든 선수 추가 성공: $successCount명');
      }
    } catch (e) {
      debugPrint('SavePlayerViewModel - 다중 선수 추가 중 예외 발생: $e');
      _state = _state.copyWith(errorMessage: '선수 추가 중 오류가 발생했습니다: $e');
    }

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  // 선수 이름으로 그룹 검색
  Future<void> searchByPlayerName(String query) async {
    if (query.isEmpty) {
      clearPlayerNameSearchResults();
      return;
    }
    
    debugPrint('SavePlayerViewModel - 선수 이름으로 그룹 검색 시작: "$query"');
    
    // 검색 결과를 저장할 Set (중복 방지)
    final Set<int> matchedGroupIds = {};
    // 그룹별로 매치된 선수 이름을 저장할 Map
    final Map<int, List<String>> matchedPlayerNamesByGroup = {};
    
    try {
      // 모든 그룹을 순회하며 선수 목록을 확인
      for (final group in _state.groups) {
        // 캐시된 선수 목록이 있으면 사용
        List<PlayerModel> players;
        
        if (_playerListCache.containsKey(group.id)) {
          players = _playerListCache[group.id]!;
        } else {
          // 캐시에 없으면 그룹의 선수 목록 조회
          final result = await _getGroupUseCase.execute(group.id);
          if (result.isSuccess) {
            players = result.value.players
                .map((player) => PlayerModel(id: player.id, name: player.name))
                .toList();
            
            // 조회한 선수 목록을 캐시에 저장
            _playerListCache[group.id] = players;
          } else {
            continue; // 조회 실패시 다음 그룹으로
          }
        }
        
        // 검색어와 일치하는 선수 이름 찾기
        final lowerQuery = query.toLowerCase();
        final matchingPlayers = players
            .where((player) => player.name.toLowerCase().contains(lowerQuery))
            .map((player) => player.name)
            .toList();
        
        // 매치된 선수가 있으면 결과에 추가
        if (matchingPlayers.isNotEmpty) {
          matchedGroupIds.add(group.id);
          matchedPlayerNamesByGroup[group.id] = matchingPlayers;
          debugPrint('SavePlayerViewModel - 선수 이름 매칭 그룹 발견: 그룹 ID ${group.id} (${group.name}), 매치된 선수: ${matchingPlayers.join(', ')}');
        }
      }
      
      // 검색 결과 상태 업데이트
      _state = _state.copyWith(
        playerSearchMatchedGroupIds: matchedGroupIds.toList(),
        matchedPlayerNamesByGroup: matchedPlayerNamesByGroup,
      );
      notifyListeners();
      
      debugPrint('SavePlayerViewModel - 선수 이름 검색 완료: ${matchedGroupIds.length}개 그룹 매칭');
    } catch (e) {
      debugPrint('SavePlayerViewModel - 선수 이름 검색 중 예외 발생: $e');
    }
  }

  // 선수 이름 검색 결과 초기화
  void clearPlayerNameSearchResults() {
    if (_state.playerSearchMatchedGroupIds.isNotEmpty || _state.matchedPlayerNamesByGroup.isNotEmpty) {
      _state = _state.copyWith(
        playerSearchMatchedGroupIds: [],
        matchedPlayerNamesByGroup: {},
      );
      notifyListeners();
      debugPrint('SavePlayerViewModel - 선수 이름 검색 결과 초기화됨');
    }
  }
}
