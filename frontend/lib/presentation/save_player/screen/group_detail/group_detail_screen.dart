import 'package:bracket_helper/core/presentation/components/square_icon_menu.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/presentation/save_player/components/player_list_item.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class GroupDetailScreen extends StatelessWidget {
  final Group group;
  final List<Player> players;
  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/image/maco.png', width: 120, height: 120),
            Text(group.name, style: TST.mediumTextBold),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareIconMenu(
                  title: "선수 추가하기",
                  imagePath: "assets/image/persons.png",
                ),
                SizedBox(width: 20),
                SquareIconMenu(
                  title: "관리",
                  imagePath: "assets/image/setting.png",
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('선수 목록 (${players.length})', style: TST.mediumTextBold),
                Spacer(),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return PlayerListItem(
                    player: players[index],
                    index: index + 1,
                    isFirst: index == 0,
                    isLast: index == players.length - 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
