import 'dart:io';
import 'dart:typed_data';

import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/match/widgets/bracket_image_generator.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 대진표 이미지 생성 및 공유 관련 유틸리티 클래스
class BracketShareUtils {
  /// 대진표를 이미지로 캡처하고 공유하는 함수
  static Future<void> captureBracketAndShare({
    required BuildContext context,
    required TournamentModel tournament,
    required List<MatchModel> matches,
    required List<PlayerModel> players,
  }) async {
    try {
      // 로딩 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.generatingBracketImageMessage),
          duration: const Duration(seconds: 2),
        ),
      );

      // 별도의 화면으로 이동하여 이미지 생성 및 공유
      final result = await Navigator.of(context).push<Uint8List?>(
        MaterialPageRoute(
          builder: (context) => BracketImageGenerator(
            tournament: tournament,
            matches: matches,
            players: players,
          ),
        ),
      );

      if (result == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.imageCancelled)),
        );
        return;
      }

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final String sanitizedTitle = tournament.title.replaceAll(
        RegExp(r'[^\w\s]+'),
        '_',
      );
      final file = File('${tempDir.path}/bracket_$sanitizedTitle.png');
      await file.writeAsBytes(result);

      // 공유하기
      final String shareTitle = AppStrings.bracketShareTitle.replaceAll('%s', tournament.title);
      await SharePlus.instance.share(
        ShareParams(
          text: shareTitle,
          subject: shareTitle,
          files: [XFile(file.path)],
        ),
      );
    } catch (e) {
      // 에러 처리
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.bracketShareError.replaceAll('%s', e.toString())),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error sharing bracket: $e');
    }
  }
} 