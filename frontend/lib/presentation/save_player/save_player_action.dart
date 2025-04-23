import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_player_action.freezed.dart';

@freezed
sealed class SavePlayerAction with _$SavePlayerAction {
  // 그룹 관련 액션
  const factory SavePlayerAction.onGroupNameChanged(String name) = OnGroupNameChanged;
  const factory SavePlayerAction.onGroupColorSelected(Color color) = OnGroupColorSelected;
  const factory SavePlayerAction.onSaveGroup(String name, Color color) = OnSaveGroup;
  const factory SavePlayerAction.onDeleteGroup(int groupId) = OnDeleteGroup;
  const factory SavePlayerAction.onUpdateGroup({
    required int groupId, 
    String? newName, 
    Color? newColor
  }) = OnUpdateGroup;
  
  // 선수 관련 액션
  const factory SavePlayerAction.onPlayerNameChanged(String name) = OnPlayerNameChanged;
  const factory SavePlayerAction.onSavePlayer(String name, int groupId) = OnSavePlayer;
  const factory SavePlayerAction.onSaveMultiplePlayers(String names, int groupId) = OnSaveMultiplePlayers;
  const factory SavePlayerAction.onDeletePlayer(int playerId, int groupId) = OnDeletePlayer;
  const factory SavePlayerAction.onUpdatePlayer({
    required int playerId,
    required String newName,
  }) = OnUpdatePlayer;
  const factory SavePlayerAction.onMovePlayerToGroup(int playerId, int groupId) = OnMovePlayerToGroup;
  
  // 그룹 리스트 화면 관련 액션
  const factory SavePlayerAction.onSearchQueryChanged(String query) = OnSearchQueryChanged;
  const factory SavePlayerAction.onToggleGridView() = OnToggleGridView;
  
  // 일반 액션
  const factory SavePlayerAction.onRefresh() = OnRefresh;
  const factory SavePlayerAction.onToggleEditMode() = OnToggleEditMode;

  // 그룹 선택 액션
  const factory SavePlayerAction.onSelectGroup(int groupId) = OnSelectGroup;
}