import 'package:bracket_helper/core/presentation/components/default_date_picker.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/index.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TournamentInfoScreen extends StatefulWidget {
  final TournamentModel tournament;
  final Function(CreateTournamentAction) onAction;
  const TournamentInfoScreen({
    super.key,
    required this.tournament,
    required this.onAction,
  });

  @override
  State<TournamentInfoScreen> createState() => _TournamentInfoScreenState();
}

class _TournamentInfoScreenState extends State<TournamentInfoScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.tournament.title);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    debugPrint('TournamentInfoScreen - initState 호출');
  }

  @override
  void didUpdateWidget(TournamentInfoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('TournamentInfoScreen - didUpdateWidget 호출');

    if (oldWidget.tournament.title != widget.tournament.title) {
      _titleController.text = widget.tournament.title;
      debugPrint('TournamentInfoScreen - 타이틀 변경됨: ${widget.tournament.title}');
    }

    if (oldWidget.tournament.date != widget.tournament.date) {
      debugPrint('TournamentInfoScreen - 날짜 변경됨: ${widget.tournament.date}');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    debugPrint('TournamentInfoScreen - dispose 호출');
    super.dispose();
  }

  // BuildContext 저장 변수 추가
  BuildContext? _safeContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 현재 유효한 BuildContext를 저장
    _safeContext = context;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TournamentInfoScreen - build 호출: 날짜 ${widget.tournament.date}');

    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: CST.primary20,
        child: Column(
          children: [
            // 콘텐츠 영역 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "대회 정보 입력",
                        style: TST.headerTextBold.copyWith(
                          color: CST.primary100,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTitleSection(),
                      SizedBox(height: 16),
                      _buildDateSection(),
                      SizedBox(height: 16),
                      _buildScoreSection(),
                      SizedBox(height: 16),
                      _buildGameSettingsSection(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 고정 버튼 영역
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return SectionCardWidget(
      title: "대회명",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '대회명을 입력해주세요',
              hintStyle: TST.mediumTextRegular.copyWith(color: CST.gray3),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: CST.gray3),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CST.gray3),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CST.primary100, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.emoji_events, color: CST.primary100),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              widget.onAction(CreateTournamentAction.onTitleChanged(value));
            },
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: CST.gray2),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  "대회명을 입력하지 않으면 '[날짜] 대회'로 자동 설정됩니다.",
                  style: TST.smallerTextRegular.copyWith(color: CST.gray2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return SectionCardWidget(
      title: "대회 날짜",
      content: DefaultDatePicker(
        initialDate: widget.tournament.date,
        onDateSelected: (date) {
          debugPrint('날짜 선택됨: $date');
          widget.onAction(CreateTournamentAction.onDateChanged(date));
        },
      ),
    );
  }

  Widget _buildScoreSection() {
    return SectionCardWidget(
      title: "승점 입력",
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ScoreInputWidget(
            label: "승",
            color: CST.success,
            initialValue: widget.tournament.winPoint.toString(),
            onChanged:
                (value) => widget.onAction(
                  CreateTournamentAction.onScoreChanged(value, '승'),
                ),
          ),
          ScoreInputWidget(
            label: "무",
            color: CST.gray2,
            initialValue: widget.tournament.drawPoint.toString(),
            onChanged:
                (value) => widget.onAction(
                  CreateTournamentAction.onScoreChanged(value, '무'),
                ),
          ),
          ScoreInputWidget(
            label: "패",
            color: CST.error,
            initialValue: widget.tournament.losePoint.toString(),
            onChanged:
                (value) => widget.onAction(
                  CreateTournamentAction.onScoreChanged(value, '패'),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSettingsSection() {
    return SectionCardWidget(
      title: "경기 설정",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("1인당 게임수", style: TST.normalTextBold.copyWith(color: CST.gray1)),
          SizedBox(height: 8),
          GameCounterWidget(
            gamesPerPlayer: widget.tournament.gamesPerPlayer,
            onAction: widget.onAction,
          ),
          SizedBox(height: 16),
          Text("경기 형식", style: TST.normalTextBold.copyWith(color: CST.gray1)),
          SizedBox(height: 8),
          MatchTypeToggleWidget(
            isDoubles: widget.tournament.isDoubles,
            onAction: widget.onAction,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return NavigationButtonsWidget(
      previousText: '종료',
      onPrevious: () async {
        // 안전한 컨텍스트 사용
        final ctx = _safeContext ?? context;

        // 종료 전 확인 다이얼로그 표시
        final shouldExit = await _showExitConfirmationDialog(ctx);
        if (shouldExit) {
          if (mounted && ctx.mounted) {
            ctx.go(RoutePaths.home);
            widget.onAction(CreateTournamentAction.onDiscard());
          }
        }
      },
      onNext: () {
        // 안전한 컨텍스트 사용
        final ctx = _safeContext ?? context;
        if (!mounted || !ctx.mounted) return;

        // 프로세스 진행 상태만 업데이트
        debugPrint('TournamentInfoScreen - 다음 버튼 클릭');
        widget.onAction(CreateTournamentAction.updateProcess(1));
        ctx.go('${RoutePaths.createTournament}${RoutePaths.addPlayer}');
      },
    );
  }

  // 종료 확인 다이얼로그
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: CST.primary100,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  '대회 생성 종료',
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '대회 생성을 종료하시겠습니까?',
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
                SizedBox(height: 8),
                Text(
                  '지금까지 입력한 모든 정보는 저장되지 않습니다.',
                  style: TST.smallTextRegular.copyWith(color: CST.gray2),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: CST.white,
                  backgroundColor: CST.gray3,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('취소', style: TST.smallTextBold),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CST.primary100,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('종료하기', style: TST.smallTextBold),
              ),
            ],
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            buttonPadding: EdgeInsets.zero,
          ),
    );

    return result ?? false;
  }
}
