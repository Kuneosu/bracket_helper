import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/match/widgets/print_match_item.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 대진표 이미지 생성을 위한 화면
class BracketImageGenerator extends StatefulWidget {
  final TournamentModel tournament;
  final List<MatchModel> matches;
  final List<PlayerModel> players;

  const BracketImageGenerator({
    super.key,
    required this.tournament,
    required this.matches,
    required this.players,
  });

  @override
  State<BracketImageGenerator> createState() => _BracketImageGeneratorState();
}

class _BracketImageGeneratorState extends State<BracketImageGenerator> {
  final GlobalKey _printKey = GlobalKey();
  final bool _isCapturing = true;

  @override
  void initState() {
    super.initState();
    // 화면이 완전히 그려진 후 캡처 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAndReturn();
    });
  }

  Future<void> _captureAndReturn() async {
    try {
      // 렌더링이 확실히 완료될 때까지 대기
      await Future.delayed(const Duration(milliseconds: 300));

      // 위젯 캡처
      RenderRepaintBoundary boundary =
          _printKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // 캡처 품질 조정 (너무 높으면 메모리 문제 발생)
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        if (!mounted) return;
        Uint8List imageBytes = byteData.buffer.asUint8List();
        // 이미지 데이터 반환 후 화면 닫기
        Navigator.of(context).pop(imageBytes);
      } else {
        // 이미지 생성 실패
        if (!mounted) return;
        Navigator.of(context).pop(null);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 대진표 컨텐츠
          SingleChildScrollView(
            child: RepaintBoundary(
              key: _printKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 토너먼트 제목 헤더
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: CST.primary20,
                      child: Column(
                        children: [
                          Text(
                            widget.tournament.title,
                            style: TST.mediumTextBold.copyWith(
                              color: CST.primary100,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.participantsAndMatches.replaceAll('%d', widget.players.length.toString()).replaceAll('%d', widget.matches.length.toString()),
                            style: TST.smallTextRegular.copyWith(
                              color: CST.gray2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 매치 리스트를 Column으로 그리기
                    ...widget.matches.asMap().entries.map((entry) {
                      final index = entry.key;
                      final match = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PrintMatchItem(match: match, index: index),
                      );
                    }),

                    // 푸터 정보
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        AppStrings.generatedBy,
                        style: TST.smallTextRegular.copyWith(color: CST.gray2),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 로딩 인디케이터
          if (_isCapturing)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: CST.white),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.generatingBracketImage,
                      style: TST.smallTextRegular.copyWith(color: CST.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 