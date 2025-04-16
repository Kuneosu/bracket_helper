import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/presentation/home/screen/home_screen.dart';
import 'package:flutter/material.dart';

class HomeRoot extends StatelessWidget {
  const HomeRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final tournaments = [
      Tournament(
        id: 1,
        title: 'Tournament A',
        date: DateTime.now(),
        winPoint: 1,
        drawPoint: 0,
        losePoint: 0,
        gamesPerPlayer: 1,
        isDoubles: false,
      ),
      Tournament(
        id: 2,
        title: 'Tournament B',
        date: DateTime.now(),
        winPoint: 1,
        drawPoint: 0,
        losePoint: 0,
        gamesPerPlayer: 1,
        isDoubles: false,
      ),
      Tournament(
        id: 3,
        title: 'Tournament C',
        date: DateTime.now(),
        winPoint: 1,
        drawPoint: 0,
        losePoint: 0,
        gamesPerPlayer: 1,
        isDoubles: false,
      ),
    ];
    return HomeScreen(tournaments: tournaments);
  }
}
