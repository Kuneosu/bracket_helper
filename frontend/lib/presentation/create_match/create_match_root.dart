import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/create_match/add_player_screen.dart';
import 'package:bracket_helper/presentation/create_match/create_match_screen.dart';
import 'package:bracket_helper/presentation/create_match/edit_match_screen.dart';
import 'package:bracket_helper/presentation/create_match/match_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateMatchRoot extends StatelessWidget {
  const CreateMatchRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentPageIndex = switch (location) {
      RoutePaths.matchInfo => 0,
      RoutePaths.addPlayer => 1,
      RoutePaths.editMatch => 2,
      _ => 0,
    };
    final body = switch (location) {
      RoutePaths.matchInfo => const MatchInfoScreen(),
      RoutePaths.editMatch => const EditMatchScreen(),
      RoutePaths.addPlayer => const AddPlayerScreen(),
      _ => const MatchInfoScreen(),
    };
    return CreateMatchScreen(body: body, currentPageIndex: currentPageIndex);
  }
}
