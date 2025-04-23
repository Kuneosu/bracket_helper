import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/home/home_action.dart';
import 'package:bracket_helper/presentation/home/home_view_model.dart';
import 'package:bracket_helper/presentation/home/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeRoot extends StatelessWidget {
  const HomeRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<HomeViewModel>();
    return ListenableBuilder(
      listenable: viewModel,
      builder:
          (context, child) => HomeScreen(
            tournaments: viewModel.tournaments,
            onAction: (action) {
              if (action is OnTapCreateTournament) {
                context.push(RoutePaths.createTournament);
              } else {
                viewModel.onAction(action);
              }
            },
            onHelpPressed: () => viewModel.printAllMatches(),
          ),
    );
  }
}
