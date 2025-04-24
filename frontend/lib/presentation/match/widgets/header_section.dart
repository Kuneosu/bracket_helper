import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final int playersCount;
  final int matchesCount;
  final VoidCallback onEditBracketPressed;
  final VoidCallback onShareBracketPressed;

  const HeaderSection({
    super.key,
    required this.playersCount,
    required this.matchesCount,
    required this.onEditBracketPressed,
    required this.onShareBracketPressed,
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
                    AppStrings.participantsCount.replaceAll('%d', playersCount.toString()),
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
                    AppStrings.matchesCount.replaceAll('%d', matchesCount.toString()),
                    style: TST.normalTextBold.copyWith(color: CST.gray1),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _buildActionButton(
            icon: Icons.edit, 
            label: AppStrings.editBracket, 
            onTap: onEditBracketPressed,
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.share,
            label: AppStrings.shareBracket,
            onTap: onShareBracketPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        child: Row(
          children: [
            Icon(icon, color: CST.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TST.smallTextBold.copyWith(color: CST.white)),
          ],
        ),
      ),
    );
  }
} 