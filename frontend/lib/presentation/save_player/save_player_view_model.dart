import 'package:bracket_helper/domain/use_case/group/add_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/save_player_state.dart';
import 'package:flutter/material.dart';

class SavePlayerViewModel with ChangeNotifier {
  SavePlayerState _state = SavePlayerState();
  SavePlayerState get state => _state;

  // UseCase들 주입
  final GetAllGroupsUseCase _getAllGroupsUseCase;
  final AddGroupUseCase _addGroupUseCase;

  SavePlayerViewModel({
    required GetAllGroupsUseCase getAllGroupsUseCase,
    required AddGroupUseCase addGroupUseCase,
  }) : _getAllGroupsUseCase = getAllGroupsUseCase,
       _addGroupUseCase = addGroupUseCase {
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
        // TODO: 그룹 삭제 로직 구현
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

      case OnRefresh():
        await fetchAllGroups();
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
}
