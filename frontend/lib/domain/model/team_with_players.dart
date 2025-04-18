import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/team.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_with_players.freezed.dart';

@freezed
@JsonSerializable()
class TeamWithPlayers with _$TeamWithPlayers {
  final Team team;
  final PlayerModel player1;
  final PlayerModel? player2;

  TeamWithPlayers({required this.team, required this.player1, this.player2});

  String get teamName {
    if (player2 != null) {
      return '${player1.name} / ${player2!.name}';
    } else {
      return player1.name;
    }
  }
}
