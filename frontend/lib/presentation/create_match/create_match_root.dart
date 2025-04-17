import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/create_match/screen/add_player/add_player_screen.dart';
import 'package:bracket_helper/presentation/create_match/create_match_screen.dart';
import 'package:bracket_helper/presentation/create_match/screen/edit_match/edit_match_screen.dart';
import 'package:bracket_helper/presentation/create_match/screen/match_info/match_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateMatchRoot extends StatelessWidget {
  const CreateMatchRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentPageIndex = 0;

    if (location.endsWith(RoutePaths.matchInfo)) {
      currentPageIndex = 0;
    } else if (location.endsWith(RoutePaths.editMatch)) {
      currentPageIndex = 2;
    } else if (location.endsWith(RoutePaths.addPlayer)) {
      currentPageIndex = 1;
    }

    final body = switch (currentPageIndex) {
      0 => const MatchInfoScreen(),
      1 => const AddPlayerScreen(),
      2 => const EditMatchScreen(),
      _ => const MatchInfoScreen(),
    };
    return CreateMatchScreen(body: body, currentPageIndex: currentPageIndex);
  }
}
