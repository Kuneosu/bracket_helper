import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/square_icon_menu.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/presentation/save_player/components/group_list_item.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupListScreen extends StatelessWidget {
  final List<Group> groups;
  final bool isEditMode;

  const GroupListScreen({
    super.key,
    required this.groups,
    this.isEditMode = false,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditMode) SizedBox(height: 40),
            if (!isEditMode)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareIconMenu(
                    title: '그룹 생성',
                    imagePath: 'assets/image/add.png',
                    onTap: () {
                      context.push(
                        '${RoutePaths.savePlayer}${RoutePaths.createGroup}',
                      );
                    },
                  ),
                  SizedBox(width: 20),
                  SquareIconMenu(
                    title: '관리',
                    imagePath: 'assets/image/setting.png',
                    onTap: () {},
                  ),
                ],
              ),
            SizedBox(height: 40),
            Text('그룹 목록 (${groups.length})', style: TST.mediumTextBold),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 20,
                    ),
                    child: GroupListItem(
                      group: groups[index],
                      onTap: () {
                        context.push(
                          '${RoutePaths.savePlayer}${RoutePaths.groupDetail}',
                        );
                      },
                      onRemoveTap: () {},
                      isEditMode: isEditMode,
                    ),
                  );
                },
                itemCount: groups.length,
              ),
            ),
            if (isEditMode) DefaultButton(text: '저장', onTap: () {}),
            if (isEditMode) SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
