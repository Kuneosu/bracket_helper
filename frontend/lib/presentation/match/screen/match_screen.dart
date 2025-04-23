import 'dart:io';
import 'dart:ui' as ui;

import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MatchScreen extends StatelessWidget {
  final TournamentModel tournament;
  final List<MatchModel> matches;
  final List<PlayerModel> players;
  final bool isLoading;
  final GlobalKey _bracketKey = GlobalKey();

  MatchScreen({
    super.key,
    required this.tournament,
    required this.matches,
    required this.players,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '로딩 중...',
            style: TST.mediumTextBold.copyWith(color: CST.white),
          ),
          backgroundColor: CST.primary100,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: CST.primary100),
              const SizedBox(height: 16),
              Text(
                '대진표를 불러오고 있습니다...',
                style: TST.smallTextRegular.copyWith(color: CST.gray2),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            tournament.title,
            style: TST.mediumTextBold.copyWith(color: CST.white),
          ),
          backgroundColor: CST.primary100,
          centerTitle: true,
          automaticallyImplyLeading: true,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                // 토너먼트 정보 다이얼로그 표시
                _showTournamentInfoDialog(context);
              },
              icon: Icon(Icons.info_outline, color: CST.white),
              tooltip: '토너먼트 정보',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeaderSection(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  // 대진표 탭 내용
                  _buildBracketTab(context, matches, players),
                  // 현재 순위 탭 내용
                  _buildRankTab(players),
                ],
              ),
            ),
            _buildBottomActionButtons(context),
          ],
        ),
      ),
    );
  }

  void _showTournamentInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('토너먼트 정보', style: TST.mediumTextBold),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제목: ${tournament.title}', style: TST.normalTextRegular),
                const SizedBox(height: 8),
                Text('참가자 수: ${players.length}명', style: TST.normalTextRegular),
                const SizedBox(height: 8),
                Text('경기 수: ${matches.length}경기', style: TST.normalTextRegular),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '닫기',
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }

  Widget _buildRankTab(List<PlayerModel> players) {
    return Column(
      children: [
        // 정렬 옵션 선택 UI 개선
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: CST.primary20,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('정렬:', style: TST.smallTextBold),
              _buildSortOption('이름', 'name', 'sort'),
              _buildSortOption('승점', 'points', 'points'),
              _buildSortOption('득실', 'difference', 'sort'),
            ],
          ),
        ),
        // 랭킹 테이블 섹션
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CST.gray4),
            ),
            child: Column(
              children: [
                // 테이블 헤더
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: CST.primary40,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: _buildRankHeader('순위')),
                      Expanded(flex: 2, child: _buildRankHeader('이름')),
                      Expanded(flex: 1, child: _buildRankHeader('승')),
                      Expanded(flex: 1, child: _buildRankHeader('무')),
                      Expanded(flex: 1, child: _buildRankHeader('패')),
                      Expanded(flex: 1, child: _buildRankHeader('승점')),
                      Expanded(flex: 1, child: _buildRankHeader('득실')),
                    ],
                  ),
                ),
                // 선수 목록
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final isEven = index % 2 == 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isEven ? Colors.white : CST.primary20,
                          border: Border(
                            bottom:
                                index < players.length - 1
                                    ? BorderSide(color: CST.gray4)
                                    : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildRankItem('${index + 1}', 0),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildRankItem(players[index].name, 0),
                            ),
                            Expanded(flex: 1, child: _buildRankItem('1', 0)),
                            Expanded(flex: 1, child: _buildRankItem('1', 0)),
                            Expanded(flex: 1, child: _buildRankItem('1', 0)),
                            Expanded(flex: 1, child: _buildRankItem('1', 0)),
                            Expanded(flex: 1, child: _buildRankItem('3', 0)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSortOption(String label, String value, String groupValue) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CST.primary80 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TST.smallTextBold.copyWith(
            color: isSelected ? CST.white : CST.gray1,
          ),
        ),
      ),
    );
  }

  Widget _buildRankHeader(String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TST.smallTextBold.copyWith(color: CST.gray1),
        textAlign: TextAlign.center,
      ),
    );
  }

  Container _buildRankItem(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TST.smallTextRegular,
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _captureBracketAndShare(BuildContext context) async {
    try {
      // 로딩 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('대진표 이미지를 생성 중입니다...'),
          duration: Duration(seconds: 2),
        ),
      );

      // 별도의 화면으로 이동하여 이미지 생성 및 공유
      final result = await Navigator.of(context).push<Uint8List?>(
        MaterialPageRoute(
          builder:
              (context) => _BracketImageGeneratorScreen(
                tournament: tournament,
                matches: matches,
                players: players,
              ),
        ),
      );

      if (result == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미지 생성이 취소되었습니다.')));
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
      await SharePlus.instance.share(
        ShareParams(
          text: '${tournament.title} 대진표',
          subject: '${tournament.title} 대진표',
          files: [XFile(file.path)],
        ),
      );
    } catch (e) {
      // 에러 처리
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('대진표 공유 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error sharing bracket: $e');
    }
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CST.primary20,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        indicator: BoxDecoration(
          color: CST.primary100,
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: CST.white,
        unselectedLabelColor: CST.gray2,
        labelStyle: TST.normalTextBold,
        unselectedLabelStyle: TST.normalTextRegular,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_kabaddi, size: 18),
                  SizedBox(width: 8),
                  Text('대진표'),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard, size: 18),
                  SizedBox(width: 8),
                  Text('현재 순위'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CST.primary20,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: CST.primary100),
                  const SizedBox(width: 8),
                  Text(
                    "참가 인원: ${players.length}명",
                    style: TST.normalTextBold.copyWith(color: CST.gray1),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 16, color: CST.primary100),
                  const SizedBox(width: 8),
                  Text(
                    "경기 수: ${matches.length}경기",
                    style: TST.normalTextBold.copyWith(color: CST.gray1),
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          _buildActionButton(icon: Icons.edit, label: "대진 수정", onTap: () {}),
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.share,
            label: "대진 공유",
            onTap: () => _captureBracketAndShare(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: CST.primary100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CST.primary100.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: CST.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TST.smallTextBold.copyWith(color: CST.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: CST.primary100,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shuffle, color: CST.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "섞어서 다시 돌리기",
                    style: TST.normalTextBold.copyWith(color: CST.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                context.go(RoutePaths.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CST.primary100,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, color: CST.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "경기 종료",
                    style: TST.normalTextBold.copyWith(color: CST.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketTab(
    BuildContext context,
    List<MatchModel> matchList,
    List<PlayerModel> playerList,
  ) {
    return Column(
      children: [
        // 매치 리스트 (실제 UI에서는 대회명을 표시하지 않음)
        Expanded(
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: matchList.length,
            itemBuilder: (context, index) {
              return _buildMatchList(index, matchList[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchList(int index, MatchModel match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: CST.gray4, width: 1),
      ),
      child: Row(
        children: [
          // 매치 번호
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CST.primary20,
              shape: BoxShape.circle,
            ),
            child: Text(
              "${index + 1}",
              style: TST.smallTextBold.copyWith(color: CST.primary100),
            ),
          ),
          const SizedBox(width: 10),
          // 왼쪽 팀
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  match.playerA!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                  textAlign: TextAlign.right,
                ),
                Container(
                  width: 40,
                  height: 1,
                  color: CST.gray4,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                Text(
                  match.playerC!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // 왼쪽 점수
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CST.primary60, width: 1),
            ),
            child: DefaultTextField(textAlign: TextAlign.center, hintText: '0'),
          ),
          // VS 표시
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Text(
              ":",
              style: TST.smallTextBold.copyWith(color: CST.primary100),
            ),
          ),
          // 오른쪽 점수
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CST.primary60, width: 1),
            ),
            child: DefaultTextField(textAlign: TextAlign.center, hintText: '0'),
          ),
          const SizedBox(width: 24),
          // 오른쪽 팀
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  match.playerB!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
                Container(
                  width: 40,
                  height: 1,
                  color: CST.gray4,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                Text(
                  match.playerD!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 별도의 화면에서 이미지 생성 (Widget 생명주기 보장)
class _BracketImageGeneratorScreen extends StatefulWidget {
  final TournamentModel tournament;
  final List<MatchModel> matches;
  final List<PlayerModel> players;

  const _BracketImageGeneratorScreen({
    required this.tournament,
    required this.matches,
    required this.players,
  });

  @override
  State<_BracketImageGeneratorScreen> createState() =>
      _BracketImageGeneratorScreenState();
}

class _BracketImageGeneratorScreenState
    extends State<_BracketImageGeneratorScreen> {
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
                          SizedBox(height: 4),
                          Text(
                            "참가자 ${widget.players.length}명 · 경기 ${widget.matches.length}경기",
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
                        child: _buildMatchItemForPrint(index, match),
                      );
                    }),

                    // 푸터 정보
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        "대진표 생성: 대진 도우미",
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
                      '대진표 이미지 생성 중...',
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

  // 이미지용 매치 아이템 빌더 - 점수 입력 칸 대신 정적 텍스트 사용
  Widget _buildMatchItemForPrint(int index, MatchModel match) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CST.gray4, width: 1),
      ),
      child: Row(
        children: [
          // 매치 번호
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CST.primary20,
              shape: BoxShape.circle,
            ),
            child: Text(
              "${index + 1}",
              style: TST.smallTextBold.copyWith(color: CST.primary100),
            ),
          ),
          const SizedBox(width: 10),
          // 왼쪽 팀
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  match.playerA!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                  textAlign: TextAlign.right,
                ),
                Container(
                  width: 40,
                  height: 1,
                  color: CST.gray4,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                Text(
                  match.playerC!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 왼쪽 점수 - 입력 필드 대신 정적 텍스트로 표시
          Text("vs", style: TST.smallTextBold.copyWith(color: CST.primary100)),
          const SizedBox(width: 12),
          // 오른쪽 팀
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  match.playerB!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
                Container(
                  width: 40,
                  height: 1,
                  color: CST.gray4,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                Text(
                  match.playerD!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
