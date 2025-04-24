import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';

class ThemeDropdown extends StatelessWidget {
  final ValueChanged<String?>? onChanged;
  final String value;

  const ThemeDropdown({
    super.key,
    this.onChanged,
    this.value = AppStrings.themeLight,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: CST.primary100),
      items: [AppStrings.themeLight, AppStrings.themeDark, AppStrings.themeSystem]
          .map(
            (String value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
} 