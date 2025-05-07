import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/core/services/language_manager.dart';

class LanguageDropdown extends StatelessWidget {
  final ValueChanged<String?>? onChanged;

  const LanguageDropdown({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    String currentValue = LanguageManager.isKorean() ? AppStrings.korean : AppStrings.english;
    
    return DropdownButton<String>(
      value: currentValue,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: CST.primary100),
      items: [AppStrings.korean, AppStrings.english]
          .map(
            (String value) =>
                DropdownMenuItem<String>(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          String languageCode = newValue == AppStrings.korean ? LanguageManager.korean : LanguageManager.english;
          LanguageManager.setLanguage(languageCode);
          if (onChanged != null) {
            onChanged!(newValue);
          }
        }
      },
    );
  }
} 