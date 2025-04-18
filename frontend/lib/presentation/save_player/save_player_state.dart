import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'save_player_state.freezed.dart';
part 'save_player_state.g.dart';

@freezed
@JsonSerializable()
class SavePlayerState with _$SavePlayerState {
  final bool isLoading;
  final String? errorMessage;
  final List<GroupModel> groups;
  final List<PlayerModel> players;
  
  // 색상은 int 타입으로 저장 (Color.value)
  final int? selectedGroupColor;
  final bool isGroupNameValid;
  final bool isPlayerNameValid;
  
  // 그룹 리스트 화면 관련 상태
  final bool isGridView;
  final String searchQuery;
  final bool isEditMode;
  
  // 선택된 그룹 ID
  final int? selectedGroupId;
  
  SavePlayerState({
    this.isLoading = false,
    this.errorMessage,
    this.groups = const [],
    this.players = const [],
    this.selectedGroupColor,
    this.isGroupNameValid = false,
    this.isPlayerNameValid = false,
    this.isGridView = false,
    this.searchQuery = '',
    this.isEditMode = false,
    this.selectedGroupId,
  });

  factory SavePlayerState.fromJson(Map<String, Object?> json) =>
      _$SavePlayerStateFromJson(json);

  Map<String, dynamic> toJson() => _$SavePlayerStateToJson(this);

  List<GroupModel> get filteredGroups {
    if (searchQuery.isEmpty) {
      return groups;
    }
    return groups.where(
      (group) => group.name.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }
  
  // 디버그 정보를 문자열로 반환
  @override
  String toString() {
    return 'SavePlayerState(isGridView: $isGridView, searchQuery: "$searchQuery", '
           'isEditMode: $isEditMode, groups: ${groups.length}, filteredGroups: ${filteredGroups.length})';
  }

  // 선택된 그룹 가져오기
  GroupModel? get selectedGroup {
    if (selectedGroupId == null) return null;
    final group = groups.firstWhere(
      (group) => group.id == selectedGroupId,
      orElse: () => const GroupModel(id: 0, name: '그룹을 찾을 수 없음'),
    );
    
    // 그룹 정보 디버그 로그
    debugPrint('SavePlayerState.selectedGroup - ID: $selectedGroupId, 그룹 찾음: ${group.id != 0}, 그룹 이름: ${group.name}');
    debugPrint('SavePlayerState.selectedGroup - 현재 그룹 목록: ${groups.map((g) => "${g.id}:${g.name}").join(", ")}');
    
    // ID가 0인 경우는 그룹을 찾지 못한 경우이므로 null 반환
    return group.id != 0 ? group : null;
  }
}
