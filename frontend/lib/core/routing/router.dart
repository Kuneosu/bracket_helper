import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/create_tournament/screens/create_tournament_root.dart';
import 'package:bracket_helper/presentation/home/screens/home_root.dart';
import 'package:bracket_helper/presentation/main/main_screen.dart';
import 'package:bracket_helper/presentation/match/screens/match_root.dart';
import 'package:bracket_helper/presentation/save_player/screens/save_player_root.dart';
import 'package:bracket_helper/presentation/setting/screens/setting_screen.dart';
import 'package:bracket_helper/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// route-aware 위젯을 지원하기 위한 RouteObserver
final routeObserver = RouteObserver<PageRoute>();

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
    
    // 홈 화면에서 그룹 관리로 이동하는 경우, 탭 인덱스를 변경하는 대신 
    // 동일한 라우트를 사용하도록 처리 (중복 인스턴스 방지)
    if (state.uri.path == RoutePaths.savePlayer && state.uri.queryParameters.containsKey('refresh')) {
      // 이미 올바른 경로에 있으므로 리다이렉션은 필요 없음
      return null;
    }
    
    return null; // 다른 스킴은 정상 처리
  },
  
  // 네비게이션 관찰자 추가
  observers: [routeObserver],
  
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
