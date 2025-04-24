import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/create_tournament/screens/create_tournament_root.dart';
import 'package:bracket_helper/presentation/home/screens/home_root.dart';
import 'package:bracket_helper/presentation/main/main_screen.dart';
import 'package:bracket_helper/presentation/match/screens/match_root.dart';
import 'package:bracket_helper/presentation/save_player/screens/save_player_root.dart';
import 'package:bracket_helper/presentation/setting/screen/setting_screen.dart';
import 'package:bracket_helper/main.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: RoutePaths.home,
  
  // URL 스킴 처리를 위한 리다이렉션 설정
  redirect: (context, state) {
    // mailto 스킴을 처리하려고 할 때
    if (state.uri.scheme == 'mailto') {
      // mailto 스트림으로 URI 전달
      mailtoLinkStream.add(state.uri);
      // 홈 화면으로 리다이렉트
      return RoutePaths.setting;
    }
    return null; // 다른 스킴은 정상 처리
  },
  
  routes: [
    GoRoute(
      path: RoutePaths.match,
      builder: (context, state) {
        final String? tournamentId = state.uri.queryParameters['tournamentId'];
        return MatchRoot(tournamentIdStr: tournamentId);
      },
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
