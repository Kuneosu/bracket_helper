import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:go_router/go_router.dart';
import 'package:bracket_helper/presentation/match/match_view_model.dart';
import 'package:bracket_helper/presentation/match/screens/match_screen.dart';
import 'package:flutter/material.dart';

class MatchRoot extends StatefulWidget {
  final String? tournamentIdStr;

  const MatchRoot({super.key, this.tournamentIdStr});

  @override
  State<MatchRoot> createState() => _MatchRootState();
}

class _MatchRootState extends State<MatchRoot> {
  late MatchViewModel viewModel;
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    
    // ViewModel 초기화는 didChangeDependencies로 이동
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 컨텍스트가 준비된 후 쿼리 파라미터 읽기
    final GoRouterState state = GoRouterState.of(context);
    final Map<String, String> queryParams = state.uri.queryParameters;
    
    // 파라미터 정보 로깅
    debugPrint('쿼리 파라미터: $queryParams');
    
    // tournamentId 변환 (기본값 1)
    final String? tournamentIdStr = queryParams['tournamentId'];
    final int tournamentId = int.tryParse(tournamentIdStr ?? '') ?? 1;
    
    // shouldRefresh 파라미터 확인
    final bool shouldRefresh = queryParams['shouldRefresh'] == 'true';
    
    debugPrint('MatchRoot 초기화: tournamentId=$tournamentId, shouldRefresh=$shouldRefresh');
    
    // ViewModel 한 번만 초기화
    if (!_isViewModelInitialized) {
      _isViewModelInitialized = true;
      
      // ViewModel 생성
      viewModel = getIt<MatchViewModel>(param1: tournamentId);
      
      // 첫 진입이거나 refresh 필요 없으면 여기서 초기화 실행
      if (!shouldRefresh) {
        debugPrint('일반 진입 - 기본 초기화 진행');
      } else {
        // shouldRefresh가 true이면 데이터 새로고침 필요
        debugPrint('대진 수정 후 돌아옴 - 데이터 새로고침 필요');
        _needsRefresh = true;
      }
    }
    
    // 새로고침이 필요한 경우에만 데이터 다시 로드
    if (_needsRefresh) {
      debugPrint('데이터 새로고침 시작');
      
      // 다음 프레임에서 새로고침 실행
      Future.microtask(() {
        if (mounted) {
          viewModel.init();
          _needsRefresh = false; // 새로고침 완료 표시
        }
      });
    }
  }

  // ViewModel 초기화 여부 추적
  bool _isViewModelInitialized = false;

  @override
  Widget build(BuildContext context) {
    // ViewModel이 아직 초기화되지 않았으면 로딩 표시
    if (!_isViewModelInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return MatchScreen(
          tournament: viewModel.state.tournament,
          matches: viewModel.state.matches,
          players: viewModel.state.players,
          isLoading: viewModel.state.isLoading,
          sortOption: viewModel.state.sortOption,
          playerStats: viewModel.playerStats,
          onAction: (action) {
            // 액션 처리
            viewModel.onAction(action, context);
          },
        );
      },
    );
  }
}
