import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/add_player/add_player_screen.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/create_tournament_screen.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/edit_match/edit_match_screen.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/tournament_info/tournament_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateTournamentRoot extends StatelessWidget {
  const CreateTournamentRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final viewModel = getIt<CreateTournamentViewModel>();

    int currentPageIndex = 0;

    if (location.endsWith(RoutePaths.tournamentInfo)) {
      currentPageIndex = 0;
    } else if (location.endsWith(RoutePaths.addPlayer)) {
      currentPageIndex = 1;
    } else if (location.endsWith(RoutePaths.editMatch)) {
      currentPageIndex = 2;
    }

    final body = switch (currentPageIndex) {
      0 => TournamentInfoScreen(tournament: viewModel.state.tournament),
      1 => const AddPlayerScreen(),
      2 => const EditMatchScreen(),
      _ => TournamentInfoScreen(tournament: viewModel.state.tournament),
    };

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return CreateTournamentScreen(
          body: body,
          currentPageIndex: currentPageIndex,
        );
      },
    );
  }
}
