import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/create_match/create_match_screen.dart';
import 'package:bracket_helper/presentation/db_test/db_test_screen.dart';
import 'package:bracket_helper/presentation/home/home_screen.dart';
import 'package:bracket_helper/presentation/main/main_screen.dart';
import 'package:bracket_helper/presentation/match/match_screen.dart';
import 'package:bracket_helper/presentation/save_player/save_player_screen.dart';
import 'package:bracket_helper/presentation/setting/setting_screen.dart';
import 'package:bracket_helper/presentation/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: RoutePaths.home,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.savePlayer,
      builder: (context, state) => const SavePlayerScreen(),
    ),
    GoRoute(
      path: RoutePaths.match,
      builder: (context, state) => const MatchScreen(),
    ),
    GoRoute(
      path: RoutePaths.createMatch,
      builder: (context, state) => const CreateMatchScreen(),
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
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomeScreen(),
              
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
