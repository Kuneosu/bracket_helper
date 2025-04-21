import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/tournament_info/tournament_info_screen.dart';
import 'package:flutter/widgets.dart';

class TournamentInfoRoot extends StatelessWidget {
  final CreateTournamentViewModel viewModel;
  const TournamentInfoRoot({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        debugPrint('TournamentInfoRoot rebuild with date: ${viewModel.state.tournament.date}');
        return TournamentInfoScreen(
          tournament: viewModel.state.tournament,
          onAction: (action) {
            viewModel.onAction(action);
          },
        );
      },
    );
  }
}
