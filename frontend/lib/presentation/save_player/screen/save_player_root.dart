import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/save_player/save_player_view_model.dart';
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
    final viewModel = getIt<SavePlayerViewModel>();
    // 현재 URL에서 마지막 경로 부분을 추출
    final location = GoRouterState.of(context).matchedLocation;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        String title = '그룹 생성';
        Widget body;
        bool showBackButton = false;

        // 선택된 색상 계산 (기본값: 파란색)
        final selectedColor =
            viewModel.state.selectedGroupColor != null
                ? Color(viewModel.state.selectedGroupColor!)
                : Colors.blue;

        // 그룹 생성 화면 생성
        final createGroupRoot = CreateGroupRoot(
          isGroupNameValid: viewModel.state.isGroupNameValid,
          selectedColor: selectedColor,
          onAction: (action) => viewModel.onAction(action),
        );

        if (location.endsWith(RoutePaths.groupList)) {
          title = '그룹 목록';
          body = GroupListRoot(
            groups: viewModel.state.groups,
            viewModel: viewModel,
          );
          showBackButton = false;
        } else if (location.endsWith(RoutePaths.groupDetail)) {
          title = '그룹 상세';
          body = const GroupDetailRoot();
          showBackButton = true;
        } else if (location.endsWith(RoutePaths.createGroup)) {
          title = '그룹 생성';
          body = createGroupRoot;
          showBackButton = true;
        } else {
          // 기본 화면 (그룹 목록)
          title = '그룹 목록';
          body = GroupListRoot(
            groups: viewModel.state.groups,
            viewModel: viewModel,
          );
          showBackButton = false;
        }

        return SavePlayerScreen(
          title: title,
          body: body,
          showBackButton: showBackButton,
        );
      },
    );
  }
}
