import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/router.dart';
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

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp.router(
      title: '대진 도우미',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
