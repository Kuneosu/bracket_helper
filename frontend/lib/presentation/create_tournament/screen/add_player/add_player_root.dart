import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/add_player/add_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddPlayerRoot extends StatefulWidget {
  final CreateTournamentViewModel viewModel;
  const AddPlayerRoot({super.key, required this.viewModel});

  @override
  State<AddPlayerRoot> createState() => _AddPlayerRootState();
}

class _AddPlayerRootState extends State<AddPlayerRoot> {
  @override
  void initState() {
    super.initState();

    // 화면 진입 시 바로 그룹 목록 미리 로드
    _preloadGroupData();
  }

  // 그룹 목록과 관련 데이터 미리 로드
  Future<void> _preloadGroupData() async {
    debugPrint('AddPlayerRoot - 그룹 목록 미리 로드 시작');

    // 모든 그룹 목록 로드 액션 실행
    Future(() {
      widget.viewModel.onAction(const CreateTournamentAction.fetchAllGroups());
    });

    // 그룹 데이터 로드 완료 확인을 위한 짧은 지연
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('AddPlayerRoot - 그룹 목록 미리 로드 완료');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        debugPrint(
          'AddPlayerRoot - 화면 빌드: 선수 ${widget.viewModel.state.players.length}명',
        );
        if (widget.viewModel.state.players.isNotEmpty) {
          debugPrint(
            'AddPlayerRoot - 선수 목록: ${widget.viewModel.state.players.map((p) => "${p.id}:${p.name}").join(', ')}',
          );
        }
        return AddPlayerScreen(
          tournament: widget.viewModel.state.tournament,
          players: widget.viewModel.state.players,
          groups: widget.viewModel.state.groups,
          onAction: (action) {
            debugPrint('AddPlayerRoot - 액션 전달: $action');

            // 선수 목록 조회 액션의 경우 처리 방식 수정
            if (action is LoadPlayersFromGroup) {
              // 빌드 중 상태 변경을 방지하기 위해 Future로 래핑
              Future(() {
                widget.viewModel.onAction(action);
              });
              // 액션 결과를 반환하지 않음
              return;
            } else {
              // 다른 모든 액션은 그대로 전달
              return widget.viewModel.onAction(action);
            }
          },
          getPlayersInGroup: (int groupId) {
            // 뷰모델의 캐시된 데이터를 조회하는 메서드 전달
            return widget.viewModel.getPlayersInGroupSync(groupId);
          },
        );
      },
    );
  }
}
