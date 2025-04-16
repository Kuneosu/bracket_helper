import 'package:bracket_helper/presentation/save_player/screen/group_list_screen.dart';
import 'package:bracket_helper/presentation/save_player/screen/save_player_screen.dart';
import 'package:flutter/material.dart';

class SavePlayerRoot extends StatelessWidget {
  const SavePlayerRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return SavePlayerScreen(title: '그룹 목록', body: GroupListScreen());
  }
}
