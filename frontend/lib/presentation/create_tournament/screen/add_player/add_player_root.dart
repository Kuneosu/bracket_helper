import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/add_player/add_player_screen.dart';
import 'package:flutter/widgets.dart';

class AddPlayerRoot extends StatelessWidget {
  final CreateTournamentViewModel viewModel;
  const AddPlayerRoot({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return AddPlayerScreen(
          tournament: viewModel.state.tournament,
          players: viewModel.state.players,
          onAction: (action) {
            viewModel.onAction(action);
          },
        );
      },
    );
  }
} 