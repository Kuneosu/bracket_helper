import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/screen/create_group/create_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGroupRoot extends StatefulWidget {
  final bool isGroupNameValid;
  final Color selectedColor;
  final Function(SavePlayerAction) onAction;

  const CreateGroupRoot({
    super.key,
    required this.isGroupNameValid,
    required this.selectedColor,
    required this.onAction,
  });

  @override
  State<CreateGroupRoot> createState() => _CreateGroupRootState();
}

class _CreateGroupRootState extends State<CreateGroupRoot> {
  // 항상 내부에서 컨트롤러 생성 및 관리
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // 이벤트 리스너 추가
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 이벤트 리스너 제거 및 컨트롤러 해제
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  // 텍스트 변경 이벤트 핸들러
  void _onTextChanged() {
    final text = _controller.text;
    widget.onAction(SavePlayerAction.onGroupNameChanged(text));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CreateGroupRoot.build - isFormValid: ${widget.isGroupNameValid}');
    
    return CreateGroupScreen(
      groupNameController: _controller,
      isFormValid: widget.isGroupNameValid,
      // TextField의 onChanged 이벤트에서도 직접 액션 호출하도록 설정
      onGroupNameChanged: (text) {
        debugPrint('직접 호출된 onGroupNameChanged: $text');
        widget.onAction(SavePlayerAction.onGroupNameChanged(text));
      },
      selectedColor: widget.selectedColor,
      onColorSelected: (color) {
        widget.onAction(SavePlayerAction.onGroupColorSelected(color));
      },
      onSaveGroup: () {
        // 액션을 통해 그룹 저장 요청
        widget.onAction(
          SavePlayerAction.onSaveGroup(
            _controller.text.trim(),
            widget.selectedColor,
          ),
        );

        // 그룹 목록 화면으로 이동
        context.go('${RoutePaths.savePlayer}${RoutePaths.groupList}');
      },
    );
  }
}
