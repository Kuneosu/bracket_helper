import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/presentation/home/widget/default_menu_card.dart';
import 'package:bracket_helper/presentation/home/widget/recent_tournament_card.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Tournament> tournaments;
  const HomeScreen({super.key, required this.tournaments});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 120,
                color: CST.primary100,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  Text("도움말", style: TST.normalTextBold.copyWith(color: CST.white)),
                ],
              ),
            ),
            Positioned(
              top: 35,
              left: 20,
              right: 0,
              child: Text(
                "최근 경기",
                style: TST.normalTextBold.copyWith(color: CST.white),
              ),
            ),
            Positioned(
              top: 55,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: tournaments.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: RecentTournamentCard(
                        tournament: tournaments[index],
                        onTapCard: () {},
                        onTapDelete: () {},
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 165,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    DefaultMenuCard(
                      title: "대진표\n생성하기",
                      subtitle: "복식/단식 매칭",
                      imagePath: "assets/image/logo_760.png",
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
