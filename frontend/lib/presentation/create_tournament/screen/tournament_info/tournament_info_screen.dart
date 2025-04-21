import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/core/presentation/components/default_date_picker.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
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
  }

  @override
  void didUpdateWidget(TournamentInfoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tournament.title != widget.tournament.title) {
      _titleController.text = widget.tournament.title;
    }

    if (oldWidget.tournament.date != widget.tournament.date) {
      debugPrint('날짜 변경됨: ${widget.tournament.date}');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TournamentInfoScreen rebuild: ${widget.tournament.date}');

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

  Widget _buildSection({required String title, required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TST.largeTextBold.copyWith(color: CST.primary100),
            ),
            SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return _buildSection(
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
    return _buildSection(
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
    return _buildSection(
      title: "승점 입력",
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreInput(
            "승",
            CST.success,
            widget.tournament.winPoint.toString(),
            (value) => widget.onAction(
              CreateTournamentAction.onScoreChanged(value, '승'),
            ),
          ),
          _buildScoreInput(
            "무",
            CST.gray2,
            widget.tournament.drawPoint.toString(),
            (value) => widget.onAction(
              CreateTournamentAction.onScoreChanged(value, '무'),
            ),
          ),
          _buildScoreInput(
            "패",
            CST.error,
            widget.tournament.losePoint.toString(),
            (value) => widget.onAction(
              CreateTournamentAction.onScoreChanged(value, '패'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInput(
    String label,
    Color color,
    String initialValue,
    Function(String) onChanged,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TST.largeTextRegular.copyWith(color: Colors.white),
          ),
        ),
        Container(
          width: 60,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: DefaultTextField(
            hintText: '0',
            textAlign: TextAlign.center,
            initialValue: initialValue,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildGameSettingsSection() {
    return _buildSection(
      title: "경기 설정",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("1인당 게임수", style: TST.normalTextBold.copyWith(color: CST.gray1)),
          SizedBox(height: 8),
          _buildMatchPerPlayer(),
          SizedBox(height: 16),
          Text("경기 형식", style: TST.normalTextBold.copyWith(color: CST.gray1)),
          SizedBox(height: 8),
          _buildMatchTypeToggle(),
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
              // 홈 화면으로 이동
              context.go(RoutePaths.home);
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
              widget.onAction(CreateTournamentAction.updateProcess(1));
              context.push(
                '${RoutePaths.createTournament}${RoutePaths.addPlayer}',
              );
            },
            color: CST.primary100,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CST.primary100),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 46,
      child: Row(
        children: [
          // 복식 버튼
          Expanded(
            child: InkWell(
              onTap: () {
                widget.onAction(
                  CreateTournamentAction.onIsDoublesChanged(true),
                );
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      widget.tournament.isDoubles
                          ? CST.primary100
                          : Colors.white,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(7),
                    right: Radius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 18,
                      color:
                          widget.tournament.isDoubles
                              ? Colors.white
                              : CST.primary100,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "복식",
                      style: TST.normalTextBold.copyWith(
                        color:
                            widget.tournament.isDoubles
                                ? Colors.white
                                : CST.primary100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 단식 버튼
          Expanded(
            child: InkWell(
              onTap: () {
                widget.onAction(
                  CreateTournamentAction.onIsDoublesChanged(false),
                );
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      !widget.tournament.isDoubles
                          ? CST.primary100
                          : Colors.white,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.zero,
                    right: Radius.circular(7),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color:
                          !widget.tournament.isDoubles
                              ? Colors.white
                              : CST.primary100,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "단식",
                      style: TST.normalTextBold.copyWith(
                        color:
                            !widget.tournament.isDoubles
                                ? Colors.white
                                : CST.primary100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchPerPlayer() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCounterButton(
            icon: Icons.remove,
            onTap: () {
              if (widget.tournament.gamesPerPlayer > 1) {
                widget.onAction(
                  CreateTournamentAction.onGamesPerPlayerChanged(
                    (widget.tournament.gamesPerPlayer - 1).toString(),
                  ),
                );
              }
            },
            isLeft: true,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: CST.primary100, width: 1),
            ),
            child: Text(
              "${widget.tournament.gamesPerPlayer}",
              style: TST.largeTextBold.copyWith(color: CST.primary100),
            ),
          ),
          _buildCounterButton(
            icon: Icons.add,
            onTap: () {
              widget.onAction(
                CreateTournamentAction.onGamesPerPlayerChanged(
                  (widget.tournament.gamesPerPlayer + 1).toString(),
                ),
              );
            },
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: CST.primary100,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? Radius.circular(8) : Radius.zero,
            right: !isLeft ? Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
