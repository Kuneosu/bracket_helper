import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';

class ContributorItem extends StatelessWidget {
  final String name;
  final String role;

  const ContributorItem({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CST.primary20.withValues(alpha:0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CST.primary40.withValues(alpha:0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CST.primary40, CST.primary20],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CST.primary100.withValues(alpha:0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 20,
                color: CST.primary100,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TST.smallTextBold.copyWith(color: CST.gray1),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TST.smallerTextRegular.copyWith(
                    color: CST.primary100.withValues(alpha:0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.favorite,
            size: 16,
            color: CST.secondary100.withValues(alpha:0.7),
          ),
        ],
      ),
    );
  }
} 