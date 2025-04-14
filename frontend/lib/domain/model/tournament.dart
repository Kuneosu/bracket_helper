// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tournament.freezed.dart';

@freezed
@JsonSerializable()
class Tournament with _$Tournament {
  final int id;
  final String title;
  final DateTime date;
  final int winPoint;
  final int drawPoint;
  final int losePoint;
  final int gamesPerPlayer;
  final bool isDoubles;

  const Tournament({
    required this.id,
    required this.title,
    required this.date,
    this.winPoint = 1,
    this.drawPoint = 0,
    this.losePoint = 0,
    this.gamesPerPlayer = 4,
    this.isDoubles = true,
  });
}
