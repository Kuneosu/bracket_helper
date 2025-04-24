import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class EditPlayerDialog extends StatelessWidget {
  final PlayerModel player;
  final Function(int, String) onUpdate;

  const EditPlayerDialog({
    super.key,
    required this.player,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // 텍스트 컨트롤러에 현재 선수 이름 설정
    final nameController = TextEditingController(text: player.name);
    final formKey = GlobalKey<FormState>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 아이콘
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CST.primary100.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: CST.primary100,
                  size: 36,
                ),
              ),
              const SizedBox(height: 15),

              // 제목
              Text(
                AppStrings.editPlayerTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 이름 입력 필드
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.playerNameLabel,
                  hintText: AppStrings.enterNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.nameValidationError;
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 25),

              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 취소 버튼
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      AppStrings.cancelButton,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 저장 버튼
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        // 다이얼로그 닫기
                        Navigator.of(context).pop();

                        // 선수 정보 업데이트 콜백 호출
                        onUpdate(player.id, nameController.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CST.primary100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      AppStrings.saveButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 다이얼로그를 표시하는 정적 메서드
  static Future<void> show({
    required BuildContext context,
    required PlayerModel player,
    required Function(int, String) onUpdate,
  }) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => EditPlayerDialog(player: player, onUpdate: onUpdate),
    );
  }
}
