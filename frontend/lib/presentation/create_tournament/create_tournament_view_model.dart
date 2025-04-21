import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_state.dart';
import 'package:flutter/material.dart';

class CreateTournamentViewModel with ChangeNotifier {
  CreateTournamentState _state = CreateTournamentState(
    tournament: TournamentModel(id: 0, title: '', date: DateTime.now()),
  );
  CreateTournamentState get state => _state;
}
