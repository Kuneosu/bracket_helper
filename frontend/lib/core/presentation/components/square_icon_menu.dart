import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class SquareIconMenu extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  const SquareIconMenu({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: CST.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CST.black.withValues(alpha: 0.1),
              blurRadius: 6,
              spreadRadius: 2,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 70, height: 70),
            SizedBox(height: 10),
            Text(title, style: TST.normalTextBold),
          ],
        ),
      ),
    );
  }
}
