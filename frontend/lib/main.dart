import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/router.dart';
import 'package:bracket_helper/core/services/language_service.dart';
import 'package:bracket_helper/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// mailto URL 처리를 위한 스트림 컨트롤러
final StreamController<Uri> mailtoLinkStream = StreamController<Uri>.broadcast();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // 의존성 설정 초기화
  await setupDependencies();
  
  // 언어 서비스 초기화
  await LanguageService.initialize();
  
  // SharedPreferences 초기화
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences 초기화 오류: $e');
  }
  
  // 화면 방향 고정 (세로 모드만)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 시스템 UI 모드 설정
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // 앱의 현재 언어 상태
  late String _currentLanguage;
  
  @override
  void initState() {
    super.initState();
    // 초기 언어 설정
    _currentLanguage = LanguageService.languageChangeNotifier.value;
    
    // 언어 변경 감지를 위한 리스너 등록
    LanguageService.languageChangeNotifier.addListener(_onLanguageChanged);
  }
  
  @override
  void dispose() {
    // 리스너 제거
    LanguageService.languageChangeNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }
  
  // 언어 변경 시 앱 UI 갱신
  void _onLanguageChanged() {
    setState(() {
      _currentLanguage = LanguageService.languageChangeNotifier.value;
      debugPrint('언어가 변경되었습니다: $_currentLanguage');
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp.router(
      title: '대진 도우미',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // 언어 변경 시 앱 다시 구축을 위한 키 추가
      key: ValueKey(_currentLanguage),
    );
  }
}
