import 'package:bracket_helper/domain/use_case/group/add_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/delete_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/count_players_in_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/update_group_use_case.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/save_player_state.dart';
import 'package:flutter/material.dart';

class SavePlayerViewModel with ChangeNotifier {
  SavePlayerState _state = SavePlayerState();
  SavePlayerState get state => _state;

  // UseCase들 주입
  final GetAllGroupsUseCase _getAllGroupsUseCase;
  final AddGroupUseCase _addGroupUseCase;
  final CountPlayersInGroupUseCase _countPlayersInGroupUseCase;
  final DeleteGroupUseCase _deleteGroupUseCase;
  final UpdateGroupUseCase _updateGroupUseCase;

  // 그룹별 선수 수 캐시
  final Map<int, int> _playerCountCache = {};

  SavePlayerViewModel({
    required GetAllGroupsUseCase getAllGroupsUseCase,
    required AddGroupUseCase addGroupUseCase,
    required CountPlayersInGroupUseCase countPlayersInGroupUseCase,
    required DeleteGroupUseCase deleteGroupUseCase,
    required UpdateGroupUseCase updateGroupUseCase,
  }) : _getAllGroupsUseCase = getAllGroupsUseCase,
       _addGroupUseCase = addGroupUseCase,
       _countPlayersInGroupUseCase = countPlayersInGroupUseCase,
       _deleteGroupUseCase = deleteGroupUseCase,
       _updateGroupUseCase = updateGroupUseCase {
    fetchAllGroups();
  }

  Future<void> fetchAllGroups() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    final result = await _getAllGroupsUseCase.execute();
    if (result.isSuccess) {
      _state = _state.copyWith(groups: result.value);
    } else {
      _state = _state.copyWith(errorMessage: result.error.message);
    }
    _state = _state.copyWith(isLoading: false);
    notifyListeners();
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

      case OnPlayerNameChanged():
        // TODO: 플레이어 이름 변경 로직 구현
        break;

      case OnSavePlayer():
        // TODO: 플레이어 저장 로직 구현
        break;

      case OnDeletePlayer():
        // TODO: 플레이어 삭제 로직 구현
        break;

      case OnMovePlayerToGroup():
        // TODO: 플레이어 그룹 이동 로직 구현
        break;

      case OnSearchQueryChanged(query: final query):
        updateSearchQuery(query);
        break;

      case OnToggleGridView():
        toggleGridView();
        break;

      case OnRefresh():
        await fetchAllGroups();
        break;
      case OnToggleEditMode():
        toggleEditMode();
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

    // AddGroupUseCase 호출
    final result = await _addGroupUseCase.execute(
      groupName: name,
      colorValue: color.toARGB32(),
    );

    if (result.isSuccess) {
      // 그룹 추가 성공 후 목록 다시 로드
      await fetchAllGroups();
    } else {
      // 에러 처리
      _state = _state.copyWith(
        errorMessage: '그룹 저장에 실패했습니다: ${result.error.message}',
      );
    }

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
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
    for (final group in _state.groups) {
      await fetchPlayerCount(group.id);
    }

    // UI 갱신
    notifyListeners();
  }

  // 특정 그룹의 선수 수 캐시 초기화 (갱신을 위해)
  void invalidatePlayerCount(int groupId) {
    _playerCountCache.remove(groupId);
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
      // 캐시에서 그룹 정보 제거
      _playerCountCache.remove(groupId);
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
}
