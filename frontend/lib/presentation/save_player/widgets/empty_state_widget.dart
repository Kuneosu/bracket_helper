import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.search_off,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: CST.gray3),
          const SizedBox(height: 16),
          Text(
            title,
            style: TST.mediumTextBold.copyWith(color: CST.gray2),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TST.smallTextRegular.copyWith(color: CST.gray3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 