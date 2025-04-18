import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class GroupGridItem extends StatelessWidget {
  final GroupModel group;
  final int playerCount;
  final VoidCallback onTap;

  const GroupGridItem({
    super.key,
    required this.group,
    required this.playerCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CST.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CST.black.withValues(alpha: 0.1),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: group.color ?? CST.primary60,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (group.color ?? CST.primary60).withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                group.name,
                style: TST.normalTextBold,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: CST.gray4.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 14, color: CST.gray2),
                  const SizedBox(width: 4),
                  Text(
                    playerCount.toString(),
                    style: TST.smallerTextBold.copyWith(color: CST.gray2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 