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
    
    // ViewModel 한 번만 초기화 또는 shouldRefresh=true인 경우 다시 초기화
    if (!_isViewModelInitialized || shouldRefresh) {
      debugPrint(shouldRefresh 
        ? '새로고침 요청됨 - 새 ViewModel 인스턴스 생성'
        : '첫 초기화 - ViewModel 인스턴스 생성');
      
      try {
        // 항상 새 인스턴스 생성 (MatchViewModel을 factory로 등록했기 때문에 가능)
        viewModel = getIt<MatchViewModel>(param1: tournamentId);
        
        // 초기화 완료 표시
        _isViewModelInitialized = true;
        _needsRefresh = false;
        
        debugPrint('ViewModel 생성 성공');
      } catch (e) {
        debugPrint('ViewModel 생성 중 오류: $e');
        // 오류 발생 시 다음 프레임에서 다시 시도하도록 플래그 설정
        _isViewModelInitialized = false;
        _needsRefresh = true;
      }
    } else if (shouldRefresh && !_needsRefresh) {
      // 이미 초기화된 상태에서 새로고침 요청이 온 경우
      debugPrint('기존 ViewModel에 데이터 새로고침 요청');
      _needsRefresh = true;
    }
    
    // 새로고침이 필요한 경우에만 데이터 다시 로드
    if (_needsRefresh && _isViewModelInitialized) {
      debugPrint('데이터 새로고침 시작 - 토너먼트 ID: $tournamentId');
      
      // 다음 프레임에서 새로고침 실행
      Future.microtask(() {
        if (mounted) {
          debugPrint('데이터 새로고침 실행 - DB에서 최신 데이터 로드');
          
          try {
            // 기존 뷰모델에 초기화 메서드 호출
            debugPrint('대진표 편집 완료 후 데이터 새로고침 - 초기화 메서드 호출');
            viewModel.init();
            _needsRefresh = false; // 새로고침 완료 표시
            debugPrint('데이터 새로고침 요청 완료');
          } catch (e) {
            debugPrint('데이터 새로고침 중 오류 발생: $e');
            // 오류 발생 시에도 refreshed 플래그를 false로 설정하여 무한 재시도 방지
            _needsRefresh = false;
          }
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
