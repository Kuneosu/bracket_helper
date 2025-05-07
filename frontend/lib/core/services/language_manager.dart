import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String _languageKey = 'selectedLanguage';
  static const String korean = 'ko';
  static const String english = 'en';

  static String _currentLanguage = korean;

  static String get currentLanguage => _currentLanguage;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      _currentLanguage = savedLanguage;
    }
  }

  static Future<void> setLanguage(String language) async {
    if (language == korean || language == english) {
      _currentLanguage = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
    }
  }

  static bool isKorean() {
    return _currentLanguage == korean;
  }
} 