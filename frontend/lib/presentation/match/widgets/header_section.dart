import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final int playersCount;
  final int matchesCount;
  final VoidCallback onEditBracketPressed;
  final VoidCallback onShareBracketPressed;
  final Key? shareButtonKey;

  const HeaderSection({
    super.key,
    required this.playersCount,
    required this.matchesCount,
    required this.onEditBracketPressed,
    required this.onShareBracketPressed,
    this.shareButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CST.primary20,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: CST.primary100),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.participantsCount(playersCount),
                    style: TST.normalTextBold.copyWith(color: CST.gray1),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 16, color: CST.primary100),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.matchesCount(matchesCount),
                    style: TST.normalTextBold.copyWith(color: CST.gray1),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _buildSquareButton(
            icon: Icons.edit,
            label: AppStrings.edit,
            onTap: onEditBracketPressed,
          ),
          const SizedBox(width: 10),
          _buildSquareButton(
            icon: Icons.share,
            label: AppStrings.share,
            onTap: onShareBracketPressed,
            key: shareButtonKey,
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Key? key,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 68,
        height: 68,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CST.primary100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CST.primary100.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: CST.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TST.smallTextBold.copyWith(color: CST.white),
            ),
          ],
        ),
      ),
    );
  }
} 