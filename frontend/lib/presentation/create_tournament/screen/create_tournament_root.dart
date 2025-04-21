import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/add_player/add_player_root.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/create_tournament_screen.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/edit_match/edit_match_root.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/tournament_info/tournament_info_root.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateTournamentRoot extends StatefulWidget {
  const CreateTournamentRoot({super.key});

  @override
  State<CreateTournamentRoot> createState() => _CreateTournamentRootState();
}

class _CreateTournamentRootState extends State<CreateTournamentRoot> {
  late CreateTournamentViewModel viewModel;

  @override
  void initState() {
    super.initState();

    // 기존에 등록된 뷰모델이 있다면 먼저 제거
    if (getIt.isRegistered<CreateTournamentViewModel>()) {
      getIt.unregister<CreateTournamentViewModel>();
      debugPrint('기존 CreateTournamentViewModel 제거됨');
    }

    // 뷰모델 생성 및 등록
    viewModel = CreateTournamentViewModel(getIt<CreateTournamentUseCase>());
    getIt.registerSingleton<CreateTournamentViewModel>(viewModel);
    debugPrint('CreateTournamentViewModel 등록됨');
  }

  @override
  void dispose() {
    // 뷰모델 제거
    if (getIt.isRegistered<CreateTournamentViewModel>()) {
      getIt.unregister<CreateTournamentViewModel>();
      debugPrint('CreateTournamentViewModel 제거됨');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentPageIndex = 0;

    if (location.endsWith(RoutePaths.tournamentInfo)) {
      currentPageIndex = 0;
    } else if (location.endsWith(RoutePaths.addPlayer)) {
      currentPageIndex = 1;
    } else if (location.endsWith(RoutePaths.editMatch)) {
      currentPageIndex = 2;
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final body = switch (currentPageIndex) {
          0 => TournamentInfoRoot(viewModel: viewModel),
          1 => AddPlayerRoot(viewModel: viewModel),
          2 => EditMatchRoot(viewModel: viewModel),
          _ => TournamentInfoRoot(viewModel: viewModel),
        };
        return CreateTournamentScreen(
          body: body,
          currentPageIndex: currentPageIndex,
        );
      },
    );
  }
}
