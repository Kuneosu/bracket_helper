import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  Icon(Icons.shuffle, color: CST.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.reshuffleBracket,
                    style: TST.normalTextBold.copyWith(color: CST.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                  Icon(Icons.done_all, color: CST.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.finishMatch,
                    style: TST.normalTextBold.copyWith(color: CST.white),
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