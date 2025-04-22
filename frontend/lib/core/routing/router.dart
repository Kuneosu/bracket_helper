import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/create_tournament_root.dart';
import 'package:bracket_helper/presentation/db_test/db_test_screen.dart';
import 'package:bracket_helper/presentation/home/screen/home_root.dart';
import 'package:bracket_helper/presentation/main/main_screen.dart';
import 'package:bracket_helper/presentation/match/match_root.dart';
import 'package:bracket_helper/presentation/save_player/screen/save_player_root.dart';
import 'package:bracket_helper/presentation/setting/setting_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: RoutePaths.home,
  routes: [
    GoRoute(
      path: RoutePaths.match,
      builder: (context, state) => const MatchRoot(),
    ),
    GoRoute(
      path: RoutePaths.createTournament,
      builder: (context, state) => const CreateTournamentRoot(),
      routes: [
        GoRoute(
          path: RoutePaths.tournamentInfo,
          builder: (context, state) => const CreateTournamentRoot(),
        ),
        GoRoute(
          path: RoutePaths.editMatch,
          builder: (context, state) => const CreateTournamentRoot(),
        ),
        GoRoute(
          path: RoutePaths.addPlayer,
          builder: (context, state) => const CreateTournamentRoot(),
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.dbTest,
      builder: (context, state) => const DbTestScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(
          body: navigationShell,
          currentPageIndex: navigationShell.currentIndex,
          onChangeIndex: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        );
      },
      restorationScopeId: 'mainShell',
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => HomeRoot(),
            ),
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'savePlayer',
          routes: [
            GoRoute(
              path: RoutePaths.savePlayer,
              builder: (context, state) => const SavePlayerRoot(),
              routes: [
                GoRoute(
                  path: RoutePaths.createGroup,
                  builder: (context, state) => const SavePlayerRoot(),
                ),
                GoRoute(
                  path: RoutePaths.groupDetail,
                  builder: (context, state) => const SavePlayerRoot(),
                ),
                GoRoute(
                  path: RoutePaths.groupList,
                  builder: (context, state) => const SavePlayerRoot(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.setting,
              builder: (context, state) => const SettingScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
