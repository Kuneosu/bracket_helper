// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
@JsonSerializable()
class GroupModel with _$GroupModel {
  final int id;
  final String name;
  
  // 색상 필드, JSON 직렬화를 위한 변환 로직 추가
  @JsonKey(
    fromJson: _colorFromJson,
    toJson: _colorToJson,
  )
  final Color? color;

  const GroupModel({
    required this.id, 
    required this.name, 
    this.color,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);
  
  // 색상값 변환 유틸리티 함수
  static Color? _colorFromJson(int? colorValue) {
    return colorValue != null ? Color(colorValue) : null;
  }
  
  static int? _colorToJson(Color? color) {
    return color?.toARGB32();
  }
}
