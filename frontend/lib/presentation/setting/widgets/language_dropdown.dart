import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';

class LanguageDropdown extends StatelessWidget {
  final ValueChanged<String?>? onChanged;
  final String value;

  const LanguageDropdown({
    super.key,
    this.onChanged,
    this.value = AppStrings.korean,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: CST.primary100),
      items: [AppStrings.korean, AppStrings.english]
          .map(
            (String value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
} 