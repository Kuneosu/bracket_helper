import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/match/match_action.dart';
import 'package:bracket_helper/presentation/match/match_view_model.dart';
import 'package:bracket_helper/presentation/match/widgets/bottom_action_buttons.dart';
import 'package:bracket_helper/presentation/match/widgets/bracket_tab_content.dart';
import 'package:bracket_helper/presentation/match/widgets/custom_tab_bar.dart';
import 'package:bracket_helper/presentation/match/widgets/header_section.dart';
import 'package:bracket_helper/presentation/match/widgets/rank_tab_content.dart';
import 'package:bracket_helper/presentation/match/widgets/tournament_info_dialog.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// 전역 변수로 튜토리얼 표시 여부 관리 (SharedPreferences 오류 대비)
class TutorialState {
  static bool hasShownMatchScreenTutorial = false;
}

class MatchScreen extends StatefulWidget {
  final TournamentModel tournament;
  final List<MatchModel> matches;
  final List<PlayerModel> players;
  final bool isLoading;
  final String sortOption;
  final void Function(MatchAction) onAction;
  final Map<String, PlayerStats> playerStats;

  const MatchScreen({
    super.key,
    required this.tournament,
    required this.matches,
    required this.players,
    required this.onAction,
    required this.playerStats,
    this.sortOption = 'points',
    this.isLoading = false,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  TutorialCoachMark? tutorialCoachMark;
  final shareButtonKey = GlobalKey();
  
  // SharedPreferences 키
  static const String _hasShownTutorialKey = 'has_shown_match_screen_tutorial';
  
  @override
  void initState() {
    super.initState();
    // 일정 시간 후에 튜토리얼 표시 여부 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }
  
  Future<void> _checkAndShowTutorial() async {
    // 메모리 내 상태를 먼저 확인
    if (TutorialState.hasShownMatchScreenTutorial) {
      return; // 이미 튜토리얼이 표시되었다면 종료
    }
    
    bool hasShownTutorial = false;
    
    try {
      // SharedPreferences에서 상태 확인 시도
      final prefs = await SharedPreferences.getInstance();
      hasShownTutorial = prefs.getBool(_hasShownTutorialKey) ?? false;
      
      if (!hasShownTutorial) {
        // 튜토리얼을 표시하고 메모리와 SharedPreferences에 모두 기록
        _showTutorialWithDelay();
        TutorialState.hasShownMatchScreenTutorial = true;
        
        try {
          prefs.setBool(_hasShownTutorialKey, true);
        } catch (e) {
          debugPrint('튜토리얼 상태 저장 실패: $e');
        }
      } else {
        // SharedPreferences에는 이미 표시된 기록이 있으므로 메모리에도 기록
        TutorialState.hasShownMatchScreenTutorial = true;
      }
    } catch (e) {
      debugPrint('SharedPreferences 오류 발생: $e');
      
      // 오류 발생시 튜토리얼 표시하고 메모리에만 기록
      _showTutorialWithDelay();
      TutorialState.hasShownMatchScreenTutorial = true;
    }
  }
  
  void _showTutorialWithDelay() {
    if (!mounted) return;
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showTutorial();
      }
    });
  }
  
  void _showTutorial() {
    // 이미 위젯이 해제되었으면 종료
    if (!mounted) return;
    
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: CST.primary100,
      textSkip: AppStrings.shareBracketSkip,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        debugPrint('튜토리얼 완료');
        return true;
      },
      onSkip: () {
        debugPrint('튜토리얼 건너뜀');
        return true;
      },
    )..show(context: context);
  }
  
  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: 'share_button',
        keyTarget: shareButtonKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.shareBracketGuide,
                    style: TST.mediumTextBold.copyWith(color: CST.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.shareBracketInfo,
                    style: TST.smallTextRegular.copyWith(color: CST.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              AppStrings.loading,
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
                  AppStrings.loadingBracket,
                  style: TST.smallTextRegular.copyWith(color: CST.gray2),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.tournament.title,
              style: TST.mediumTextBold.copyWith(color: CST.white),
            ),
            backgroundColor: CST.primary100,
            centerTitle: true,
            automaticallyImplyLeading: true,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  TournamentInfoDialog.show(
                    context: context,
                    tournament: widget.tournament,
                    playersCount: widget.players.length,
                    matchesCount: widget.matches.length,
                  );
                },
                icon: Icon(Icons.info_outline, color: CST.white),
                tooltip: AppStrings.tournamentInfo,
              ),
            ],
          ),
          body: Column(
            children: [
              HeaderSection(
                playersCount: widget.players.length,
                matchesCount: widget.matches.length,
                onEditBracketPressed: () {
                  // isPartnerMatching 값에 따라 다른 편집 화면으로 이동
                  if (widget.tournament.isPartnerMatching) {
                    widget.onAction(const MatchAction.editPartnerBracket());
                  } else {
                    widget.onAction(const MatchAction.editBracket());
                  }
                },
                onShareBracketPressed: () => widget.onAction(const MatchAction.captureAndShareBracket()),
                shareButtonKey: shareButtonKey,
              ),
              // 경기 점수 저장 관련 안내 메시지 추가
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: CST.primary20,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: CST.primary100, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.matchScoreInputInfo,
                        style: TST.smallTextRegular.copyWith(color: CST.primary100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16,),
              const CustomTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    // 대진표 탭
                    BracketTabContent(
                      matches: widget.matches,
                      players: widget.players,
                      onAction: widget.onAction,
                    ),                    
                    // 현재 순위 탭
                    RankTabContent(
                      players: widget.players,
                      playerStats: widget.playerStats,
                      sortOption: widget.sortOption,
                      onSortOptionSelected: (option) => widget.onAction(MatchAction.sortPlayersBy(option)),
                    ),
                  ],
                ),
              ),
              BottomActionButtons(
                onShuffleBracketPressed: () => widget.onAction(const MatchAction.shuffleBracket()),
                onFinishTournamentPressed: () => widget.onAction(const MatchAction.finishTournament()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
