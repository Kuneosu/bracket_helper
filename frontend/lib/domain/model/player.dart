// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
@JsonSerializable()
class Player with _$Player {
    final int id;
  final String name;
  const Player({required this.id, required this.name});
  
  factory Player.fromJson(Map<String, Object?> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}