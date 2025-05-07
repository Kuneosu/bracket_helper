// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:bracket_helper/core/services/language_manager.dart';
import 'package:get_it/get_it.dart';

class LanguageService {
  // 언어 변경 알림을 위한 전역 ChangeNotifier
  static final ValueNotifier<String> languageChangeNotifier =
      ValueNotifier<String>(LanguageManager.currentLanguage);

  /// 앱 시작시 호출되어야 하는 초기화 함수
  static Future<void> initialize() async {
    await LanguageManager.initialize();
    // 초기화 시 현재 언어로 Notifier 값 설정
    languageChangeNotifier.value = LanguageManager.currentLanguage;
  }

  /// 언어 변경 후 앱 UI를 다시 그리기 위한 함수
  static void refreshApp(BuildContext context) {
    // 1. 언어 변경을 알림
    languageChangeNotifier.value = LanguageManager.currentLanguage;

    // 2. 앱 전체를 다시 그리기 위해 최상위 위젯까지 이동
    if (context.mounted) {
      // 첫 번째 라우트로 이동 (홈 화면)
      Navigator.of(context).popUntil((route) => route.isFirst);

      // 3. 홈 화면에 도달한 후 재구축을 강제
      Future.delayed(const Duration(milliseconds: 100), () {
        // 모든 ViewModel 새로고침을 트리거
        final GetIt getIt = GetIt.instance;
        // 등록된 모든 ViewModel의 상태 갱신을 시도
        try {
          // HomeViewModel 갱신 시도
          if (getIt.isRegistered<ChangeNotifier>(
            instanceName: 'HomeViewModel',
          )) {
            getIt<ChangeNotifier>(
              instanceName: 'HomeViewModel',
            ).notifyListeners();
          }

          // SavePlayerViewModel 갱신 시도
          if (getIt.isRegistered<ChangeNotifier>(
            instanceName: 'SavePlayerViewModel',
          )) {
            getIt<ChangeNotifier>(
              instanceName: 'SavePlayerViewModel',
            ).notifyListeners();
          }

          // 기타 등록된 ViewModel들에 대한 갱신 시도
        } catch (e) {
          debugPrint('ViewModel 갱신 중 오류 발생: $e');
        }
      });
    }
  }
}
