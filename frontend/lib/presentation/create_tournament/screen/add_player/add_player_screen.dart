import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/add_player_bottom_sheet.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 로컬에서 간단하게 사용할 임시 선수 클래스

class AddPlayerScreen extends StatelessWidget {
  const AddPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 실제 Player 모델 대신 PlayerDto 사용
    final List<Player> players = [
      Player(id: 1, name: "홍길동"),
      Player(id: 2, name: "이순신"),
      Player(id: 3, name: "김유신"),
      Player(id: 1, name: "홍길동"),
      Player(id: 2, name: "이순신"),
      Player(id: 3, name: "김유신"),
      Player(id: 1, name: "홍길동"),
      Player(id: 2, name: "이순신"),
      Player(id: 3, name: "김유신"),
    ];

    // CreateMatchScreen이 이미 Column과 함께 body를 포함하고 있음
    // 따라서 여기서는 단일 Expanded 위젯으로 감싸서 레이아웃 충돌을 방지
    return Expanded(
      child: Column(
        children: [
          // 상단 헤더
          _buildHeader(context, players.length),

          // 목록 부분은 또 다른 Expanded로 감싸서 남은 공간을 차지하도록 설정
          Expanded(
            child: ListView.builder(
              // 오버스크롤 동작 제어를 위한 physics 설정
              physics: const ClampingScrollPhysics(),
              itemCount: players.length + 1,
              itemBuilder: (context, index) {
                if (index == players.length) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: CST.primary40,
                      border: Border(bottom: BorderSide(color: CST.gray3)),
                    ),
                    child: Center(
                      child: Text(
                        "+",
                        style: TST.mediumTextBold.copyWith(
                          color: CST.primary100,
                        ),
                      ),
                    ),
                  );
                } else {
                  return _buildPlayerItem(players[index], index + 1);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 40,
              top: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultButton(
                  text: '이전',
                  onTap: () {
                    context.pop();
                  },
                  width: 70,
                ),
                DefaultButton(
                  text: '다음',
                  onTap: () {
                    context.push(
                      '${RoutePaths.createTournament}${RoutePaths.editMatch}',
                    );
                  },
                  width: 70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 상단 헤더 위젯
  Widget _buildHeader(BuildContext context, int playerCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CST.gray3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("참가 인원 수 : $playerCount 명", style: TST.largeTextRegular),
          DefaultButton(
            text: "선수 추가하기",
            onTap: () {
              // 바텀시트 표시
              _showAddPlayerBottomSheet(context);
            },
            width: 133,
            textStyle: TST.normalTextBold,
          ),
        ],
      ),
    );
  }

  // 선수 추가 바텀시트 표시 메서드
  void _showAddPlayerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 바텀시트가 위로 올라가도록 설정
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정하여 모서리 둥글게 보이도록
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const AddPlayerBottomSheet(),
          ),
    );
  }

  // 선수 항목 위젯
  Widget _buildPlayerItem(Player player, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CST.gray3)),
      ),
      child: Row(
        children: [
          SizedBox(width: 20),
          Text("$index", style: TST.mediumTextRegular),
          Spacer(),
          Text(player.name, style: TST.mediumTextBold),
          const Spacer(),
        ],
      ),
    );
  }
}
