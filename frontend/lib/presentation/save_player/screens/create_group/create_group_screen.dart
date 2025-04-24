import 'package:bracket_helper/presentation/save_player/widgets/action_button_row.dart';
import 'package:bracket_helper/presentation/save_player/widgets/color_picker_grid.dart';
import 'package:bracket_helper/presentation/save_player/widgets/form_card.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGroupScreen extends StatelessWidget {
  final TextEditingController groupNameController;
  final bool isFormValid;
  final Color selectedColor;
  final Function(SavePlayerAction) onAction;

  const CreateGroupScreen({
    super.key,
    required this.groupNameController,
    required this.isFormValid,
    required this.selectedColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 간단한 설명
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      '그룹 정보를 입력해주세요',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),

                  // 그룹명 입력 섹션 (순서 변경)
                  FormCard(
                    icon: Icons.group,
                    title: '그룹명',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: groupNameController,
                          onChanged: (text) {
                            onAction(SavePlayerAction.onGroupNameChanged(text));
                          },
                          decoration: InputDecoration(
                            hintText: '그룹명을 입력해주세요',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '최대 20자까지 입력 가능합니다',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 그룹 색상 선택 섹션
                  FormCard(
                    icon: Icons.style,
                    title: '그룹 색상',
                    subtitle: '그룹을 대표할 색상을 선택하세요',
                    content: ColorPickerGrid(
                      selectedColor: selectedColor,
                      onColorSelected: (color) {
                        onAction(SavePlayerAction.onGroupColorSelected(color));
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 버튼 섹션
                  ActionButtonRow(
                    cancelText: '생성 취소',
                    confirmText: '그룹 생성하기',
                    onCancel: () => context.pop(),
                    onConfirm: () {
                      onAction(
                        SavePlayerAction.onSaveGroup(
                          groupNameController.text.trim(),
                          selectedColor,
                        ),
                      );
                    },
                    isConfirmEnabled: isFormValid,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
