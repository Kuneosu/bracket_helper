import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class DefaultMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final void Function() onTap;
  const DefaultMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 200,
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: CST.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: CST.black.withValues(alpha: 0.1),
                blurRadius: 6,
                spreadRadius: 2,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subtitle,
                      style: TST.normalTextRegular,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(title, style: TST.headerTextBold),
                  ],
                ),
              ),
              Image.asset(imagePath, width: 120, height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
