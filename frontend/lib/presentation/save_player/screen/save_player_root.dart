import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/save_player/screen/create_group/create_group_root.dart';
import 'package:bracket_helper/presentation/save_player/screen/group_detail/group_detail_root.dart';
import 'package:bracket_helper/presentation/save_player/screen/group_list/group_list_root.dart';
import 'package:bracket_helper/presentation/save_player/screen/save_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SavePlayerRoot extends StatelessWidget {
  const SavePlayerRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 URL에서 마지막 경로 부분을 추출
    final location = GoRouterState.of(context).matchedLocation;
    
    String title = '그룹 정보';
    Widget body = const CreateGroupRoot();
    bool showBackButton = false;
    
    if (location.endsWith(RoutePaths.groupList)) {
      title = '그룹 목록';
      body = const GroupListRoot();
      showBackButton = false;
    } else if (location.endsWith(RoutePaths.groupDetail)) {
      title = '그룹 상세';
      body = const GroupDetailRoot();
      showBackButton = true;
    }
    
    return SavePlayerScreen(
      title: title, 
      body: body,
      showBackButton: showBackButton,
    );
  }
}
