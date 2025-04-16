import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/presentation/save_player/screen/group_list/group_list_screen.dart';
import 'package:flutter/material.dart';

class GroupListRoot extends StatelessWidget {
  const GroupListRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupListScreen(
      groups: [
        Group(id: 1, name: '그룹 1'),
        Group(id: 2, name: '그룹 2'),
        Group(id: 3, name: '그룹 3'),
      ],
    );
  }
}
