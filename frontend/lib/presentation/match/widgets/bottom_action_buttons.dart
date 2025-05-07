import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/core/services/language_manager.dart';
import 'package:flutter/material.dart';

class BottomActionButtons extends StatelessWidget {
  final VoidCallback onShuffleBracketPressed;
  final VoidCallback onFinishTournamentPressed;

  const BottomActionButtons({
    super.key,
    required this.onShuffleBracketPressed,
    required this.onFinishTournamentPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 영어일 때 폰트 크기와 간격 조절을 위한 변수들
    final isKorean = LanguageManager.isKorean();
    final fontSize = isKorean ? TST.normalTextBold.fontSize : 13.0;
    final iconPadding = isKorean ? 8.0 : 4.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onShuffleBracketPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: CST.primary100,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shuffle, color: CST.white, size: isKorean ? 20 : 18),
                  SizedBox(width: iconPadding),
                  Flexible(
                    child: Text(
                      AppStrings.reshuffleBracket,
                      style: TST.normalTextBold.copyWith(
                        color: CST.white, 
                        fontSize: fontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onFinishTournamentPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: CST.primary100,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, color: CST.white, size: isKorean ? 20 : 18),
                  SizedBox(width: iconPadding),
                  Flexible(
                    child: Text(
                      AppStrings.finishMatch,
                      style: TST.normalTextBold.copyWith(
                        color: CST.white, 
                        fontSize: fontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 