import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/presentation/setting/widget/setting_item.dart';

class SettingItemWithBeta extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingItemWithBeta({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SettingItem(
          icon: icon,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        ),
        Positioned(
          top: 8,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: CST.secondary100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '준비중',
              style: TST.smallerTextBold.copyWith(color: CST.white),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.5),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }
} 