import 'package:flutter/material.dart';
import 'package:bracket_helper/core/services/language_manager.dart';

class LanguageService {
  /// 앱 시작시 호출되어야 하는 초기화 함수
  static Future<void> initialize() async {
    await LanguageManager.initialize();
  }

  /// 언어 변경 후 앱 UI를 다시 그리기 위한 함수
  static void refreshApp(BuildContext context) {
    // 상태를 갱신하여 UI를 다시 그리도록 합니다
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      // 홈 화면으로 돌아간 후 해당 화면을 다시 그립니다
      // 여기서는 간단한 방법을 사용했지만, 앱 전체를 다시 그리려면
      // Provider, GetIt 등의 상태 관리 도구를 활용하는 것이 좋습니다
    }
  }
} 