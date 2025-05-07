import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class SectionCardWidget extends StatelessWidget {
  final String title;
  final Widget content;

  const SectionCardWidget({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TST.largeTextBold.copyWith(color: CST.primary100).copyWith(fontSize: 18),
            ),
            SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
} 