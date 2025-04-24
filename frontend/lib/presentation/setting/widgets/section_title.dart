import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TST.mediumTextBold.copyWith(color: CST.primary100),
          ),
          const SizedBox(height: 8),
          Divider(color: CST.gray4, thickness: 1),
        ],
      ),
    );
  }
} 