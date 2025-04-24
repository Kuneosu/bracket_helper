import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screens/add_player/add_player_screen.dart';
import 'package:flutter/material.dart';

class AddPlayerRoot extends StatefulWidget {
  final CreateTournamentViewModel viewModel;
  const AddPlayerRoot({super.key, required this.viewModel});

  @override
  State<AddPlayerRoot> createState() => _AddPlayerRootState();
}

class _AddPlayerRootState extends State<AddPlayerRoot> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // CreateTournamentViewModel 로딩 상태 확인
    _checkLoadingState();
  }

  // 로딩 상태 체크
  void _checkLoadingState() {
    setState(() {
      _isLoading = widget.viewModel.state.isLoading;
    });
    
    // 로딩 중이라면 상태 업데이트를 위해 짧은 대기
    if (_isLoading) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isLoading = widget.viewModel.state.isLoading;
          });
        }
      });
    }
  }

  // 필요 시 선수 데이터 로드 (지연 로드 방식)
  Future<void> _loadPlayersForGroup(int groupId) async {
    try {
      widget.viewModel.onAction(
        CreateTournamentAction.loadPlayersFromGroup(groupId),
      );
    } catch (e) {
      debugPrint('AddPlayerRoot - 그룹 $groupId 선수 로드 중 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final currentGroups = List<GroupModel>.from(widget.viewModel.state.groups);
        final currentPlayers = List<PlayerModel>.from(widget.viewModel.state.players);
        
        debugPrint(
          'AddPlayerRoot - 화면 빌드: 선수 ${currentPlayers.length}명, 그룹 ${currentGroups.length}개',
        );

        return AddPlayerScreen(
          tournament: widget.viewModel.state.tournament,
          players: currentPlayers,
          groups: currentGroups,
          isLoading: _isLoading || widget.viewModel.state.isLoading,
          onAction: (action) {
            debugPrint('AddPlayerRoot - 액션 전달: $action');
            
            // 그룹 목록 새로고침 액션인 경우 로딩 상태 표시
            if (action is FetchAllGroups) {
              setState(() {
                _isLoading = true;
              });
              
              // 액션 실행
              widget.viewModel.onAction(action);
              
              // 잠시 후 로딩 상태 해제
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
              return;
            }
            
            // 기타 모든 액션 직접 전달
            return widget.viewModel.onAction(action);
          },
          getPlayersInGroup: (int groupId) {
            // 캐시된 데이터 사용
            final players = widget.viewModel.getPlayersInGroupSync(groupId);
            
            // 데이터가 없으면 백그라운드로 로드 요청 (UI 블로킹 없음)
            if (players.isEmpty && groupId != -999) {
              Future.microtask(() => _loadPlayersForGroup(groupId));
            }
            
            return players;
          },
        );
      },
    );
  }
}
