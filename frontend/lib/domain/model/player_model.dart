// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_model.freezed.dart';
part 'player_model.g.dart';

@freezed
@JsonSerializable()
class PlayerModel with _$PlayerModel {
  final int id;
  final String name;
  const PlayerModel({required this.id, required this.name});

  factory PlayerModel.fromJson(Map<String, Object?> json) =>
      _$PlayerModelFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerModelToJson(this);
}