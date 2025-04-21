import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/default_date_picker.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/tournament_info/game_counter_widget.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/tournament_info/match_type_toggle_widget.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/tournament_info/score_input_widget.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/tournament_info/section_card_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    debugPrint('TournamentInfoScreen - build 호출: 날짜 ${widget.tournament.date}');

    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: CST.primary20,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "대회 정보 입력",
                  style: TST.headerTextBold.copyWith(color: CST.primary100),
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
                _buildButtons(),
                SizedBox(height: 40), // 하단 여백 추가
              ],
            ),
          ),
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
    return Row(
      children: [
        Expanded(
          child: DefaultButton(
            text: '종료',
            onTap: () {
              context.go(RoutePaths.home);
              widget.onAction(CreateTournamentAction.onDiscard());
            },
            color: CST.gray3,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: DefaultButton(
            text: '다음',
            onTap: () {
              // 프로세스 진행 상태만 업데이트
              debugPrint('TournamentInfoScreen - 다음 버튼 클릭');
              widget.onAction(CreateTournamentAction.updateProcess(1));
              context.go(
                '${RoutePaths.createTournament}${RoutePaths.addPlayer}',
              );
            },
            color: CST.primary100,
          ),
        ),
      ],
    );
  }
}
