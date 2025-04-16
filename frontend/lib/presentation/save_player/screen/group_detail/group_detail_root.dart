import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/presentation/save_player/screen/group_detail/group_detail_screen.dart';
import 'package:flutter/material.dart';

class GroupDetailRoot extends StatelessWidget {
  const GroupDetailRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const GroupDetailScreen(
      group: Group(id: 1, name: '그룹 1'),
      players: [
        Player(id: 1, name: '선수 1'),
        Player(id: 2, name: '선수 2'),
        Player(id: 3, name: '선수 3'),
      ],
    );
  }
}
