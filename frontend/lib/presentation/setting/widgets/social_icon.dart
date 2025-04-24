import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const SocialIcon({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: CST.primary40, shape: BoxShape.circle),
        child: Icon(icon, color: CST.primary100),
      ),
    );
  }
} 