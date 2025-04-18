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
  
  // 선수 관련 액션
  const factory SavePlayerAction.onPlayerNameChanged(String name) = OnPlayerNameChanged;
  const factory SavePlayerAction.onSavePlayer(String name, int groupId) = OnSavePlayer;
  const factory SavePlayerAction.onDeletePlayer(int playerId) = OnDeletePlayer;
  const factory SavePlayerAction.onMovePlayerToGroup(int playerId, int groupId) = OnMovePlayerToGroup;
  
  // 일반 액션
  const factory SavePlayerAction.onRefresh() = OnRefresh;
} 