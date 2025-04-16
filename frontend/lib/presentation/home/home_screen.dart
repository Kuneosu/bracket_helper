import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/presentation/home/widget/recent_tournament_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Text('Home Screen'),
            RecentTournamentCard(
              tournament: Tournament(
                id: 1,
                title: 'Tournament A',
                date: DateTime.now(),
                winPoint: 1,
                drawPoint: 0,
                losePoint: 0,
                gamesPerPlayer: 1,
                isDoubles: false,
              ),
              onTapCard: () {
                debugPrint('onTapCard');
              },
              onTapDelete: () {
                debugPrint('onTapDelete');
              },
            ),
          ],
        ),
      ),
    );
  }
}
