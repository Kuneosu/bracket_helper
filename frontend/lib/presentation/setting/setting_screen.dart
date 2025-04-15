import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.push(RoutePaths.dbTest);
              },
              child: const Text('DB 테스트 화면'),
            ),
          ],
        ),
      ),
    );
  }
}
