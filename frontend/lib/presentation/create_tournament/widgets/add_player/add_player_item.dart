import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class AddPlayerItem extends StatelessWidget {
  final VoidCallback onTap;

  const AddPlayerItem({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: CST.primary40,
          border: Border(bottom: BorderSide(color: CST.gray3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: CST.primary100),
            SizedBox(width: 8),
            Text(
              "선수 추가하기",
              style: TST.mediumTextBold.copyWith(color: CST.primary100),
            ),
          ],
        ),
      ),
    );
  }
} 