// ignore_for_file: annotate_overrides

import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_model.freezed.dart';

@freezed
@JsonSerializable()
class TeamModel with _$TeamModel {
  final PlayerModel p1;
  final PlayerModel? p2; // 단식이면 null
  const TeamModel(this.p1, [this.p2]);

  // 팀 이름 getter 추가
  String get teamName {
    if (p2 != null) {
      return '${p1.name} / ${p2!.name}';
    } else {
      return p1.name;
    }
  }
}
