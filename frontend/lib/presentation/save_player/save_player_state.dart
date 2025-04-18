import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
  
  SavePlayerState({
    this.isLoading = false,
    this.errorMessage,
    this.groups = const [],
    this.players = const [],
    this.selectedGroupColor,
    this.isGroupNameValid = false,
  });

  factory SavePlayerState.fromJson(Map<String, Object?> json) =>
      _$SavePlayerStateFromJson(json);

  Map<String, dynamic> toJson() => _$SavePlayerStateToJson(this);
}
