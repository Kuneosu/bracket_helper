// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tournament_model.freezed.dart';
part 'tournament_model.g.dart';

@freezed
@JsonSerializable()
class TournamentModel with _$TournamentModel {
  final int id;
  final String title;
  final DateTime date;
  final int winPoint;
  final int drawPoint;
  final int losePoint;
  final int gamesPerPlayer;
  final bool isDoubles;
  final int process;
  final bool isPartnerMatching;
  final List<List<String>> partnerPairs;

  const TournamentModel({
    required this.id,
    required this.title,
    required this.date,
    this.winPoint = 1,
    this.drawPoint = 0,
    this.losePoint = 0,
    this.gamesPerPlayer = 4,
    this.isDoubles = true,
    this.process = 0,
    this.isPartnerMatching = false,
    this.partnerPairs = const [],
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) =>
      _$TournamentModelFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentModelToJson(this);
}
