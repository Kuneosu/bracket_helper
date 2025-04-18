import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/save_player_view_model.dart';
import 'package:bracket_helper/presentation/save_player/screen/group_list/group_list_screen.dart';
import 'package:flutter/material.dart';

class GroupListRoot extends StatefulWidget {
  final List<GroupModel> groups;
  final SavePlayerViewModel viewModel;

  const GroupListRoot({
    super.key,
    required this.groups,
    required this.viewModel,
  });

  @override
  State<GroupListRoot> createState() => _GroupListRootState();
}

class _GroupListRootState extends State<GroupListRoot> {
  @override
  void initState() {
    super.initState();
    // 초기화 시점에만 한 번 갱신
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.refreshPlayerCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        debugPrint(
          'GroupListRoot rebuild: isGridView=${widget.viewModel.state.isGridView}, '
          'searchQuery="${widget.viewModel.state.searchQuery}", '
          'isEditMode=${widget.viewModel.state.isEditMode}, '
          'groups=${widget.groups.length}',
        );

        return GroupListScreen(
          groups: widget.groups,
          isGridView: widget.viewModel.state.isGridView,
          searchQuery: widget.viewModel.state.searchQuery,
          isEditMode: widget.viewModel.state.isEditMode,
          getPlayerCount: (groupId) {
            return widget.viewModel.getPlayerCountSync(groupId);
          },
          onSearchChanged: (query) {
            debugPrint('Search query changed: $query');
            widget.viewModel.onAction(SavePlayerAction.onSearchQueryChanged(query));
          },
          onToggleView: () {
            debugPrint('Toggle view called');
            widget.viewModel.onAction(SavePlayerAction.onToggleGridView());
          },
          onToggleEditMode: () {
            debugPrint('Toggle edit mode called');
            widget.viewModel.onAction(SavePlayerAction.onToggleEditMode());
          },
          onDeleteGroup: (groupId) {
            debugPrint('Delete group: $groupId');
            widget.viewModel.onAction(SavePlayerAction.onDeleteGroup(groupId));
          },
          onUpdateGroup: (groupId, newName) {
            debugPrint('Update group name: $groupId => $newName');
            widget.viewModel.onAction(
              SavePlayerAction.onUpdateGroup(
                groupId: groupId, 
                newName: newName,
                newColor: null,
              ),
            );
          },
          onUpdateColor: (groupId, newColor) {
            debugPrint('Update group color: $groupId => $newColor');
            widget.viewModel.onAction(
              SavePlayerAction.onUpdateGroup(
                groupId: groupId,
                newName: null,
                newColor: newColor,
              ),
            );
          },
        );
      },
    );
  }
}
