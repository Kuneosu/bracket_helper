import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/edit_match/edit_match_screen.dart';
import 'package:flutter/widgets.dart';

class EditMatchRoot extends StatelessWidget {
  final CreateTournamentViewModel viewModel;
  const EditMatchRoot({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return EditMatchScreen(
          tournament: viewModel.state.tournament,
          players: viewModel.state.players,
          matches: viewModel.state.matches,
          onAction: (action) {
            viewModel.onAction(action);
          },
        );
      },
    );
  }
} 