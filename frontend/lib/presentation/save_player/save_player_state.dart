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
  
  // 선수 이름으로 검색된 그룹 ID 목록
  final List<int> playerSearchMatchedGroupIds;
  
  // 검색어와 일치하는 선수 이름 정보를 그룹별로 저장
  // 키: 그룹 ID, 값: 해당 그룹에서 검색어와 일치하는 선수 이름 목록
  final Map<int, List<String>> matchedPlayerNamesByGroup;
  
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
    this.playerSearchMatchedGroupIds = const [],
    this.matchedPlayerNamesByGroup = const {},
  });

  factory SavePlayerState.fromJson(Map<String, Object?> json) =>
      _$SavePlayerStateFromJson(json);

  Map<String, dynamic> toJson() => _$SavePlayerStateToJson(this);

  List<GroupModel> get filteredGroups {
    if (searchQuery.isEmpty) {
      return groups;
    }
    
    // 그룹 이름으로 필터링한 목록
    final groupsByName = groups.where(
      (group) => group.name.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
    
    // 선수 이름 검색 결과가 있는 경우, 해당 그룹들도 포함
    if (playerSearchMatchedGroupIds.isNotEmpty) {
      // 그룹 이름으로 필터링된 목록과 선수 이름으로 찾은 그룹 ID 목록을 합침
      final Set<int> groupIds = groupsByName.map((g) => g.id).toSet();
      
      for (final groupId in playerSearchMatchedGroupIds) {
        // 중복되지 않는 그룹 ID만 추가
        if (!groupIds.contains(groupId)) {
          final group = groups.firstWhere(
            (g) => g.id == groupId,
            orElse: () => const GroupModel(id: 0, name: ''),
          );
          
          // 유효한 그룹인 경우에만 결과에 추가
          if (group.id != 0) {
            groupsByName.add(group);
          }
        }
      }
    }
    
    return groupsByName;
  }
  
  // 디버그 정보를 문자열로 반환
  @override
  String toString() {
    return 'SavePlayerState(isGridView: $isGridView, searchQuery: "$searchQuery", '
           'isEditMode: $isEditMode, groups: ${groups.length}, filteredGroups: ${filteredGroups.length}, '
           'playerSearchMatchedGroupIds: ${playerSearchMatchedGroupIds.length})';
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
