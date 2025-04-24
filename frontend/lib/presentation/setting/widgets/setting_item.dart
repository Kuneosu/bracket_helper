import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CST.primary40,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: CST.primary100),
      ),
      title: Text(title, style: TST.normalTextBold),
      subtitle:
          subtitle != null
              ? Text(
                  subtitle!,
                  style: TST.smallTextRegular.copyWith(color: CST.gray2),
                )
              : null,
      trailing:
          trailing ??
              (onTap != null
                  ? const Icon(Icons.arrow_forward_ios, size: 16, color: CST.gray3)
                  : null),
      onTap: onTap,
    );
  }
} 