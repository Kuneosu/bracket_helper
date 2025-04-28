import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/core/routing/router.dart';
import 'package:bracket_helper/presentation/save_player/save_player_view_model.dart';
import 'package:bracket_helper/presentation/save_player/screens/create_group/create_group_root.dart';
import 'package:bracket_helper/presentation/save_player/screens/group_detail/group_detail_root.dart';
import 'package:bracket_helper/presentation/save_player/screens/group_list/group_list_root.dart';
import 'package:bracket_helper/presentation/save_player/screens/save_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SavePlayerRoot extends StatefulWidget {
  const SavePlayerRoot({super.key});

  @override
  State<SavePlayerRoot> createState() => _SavePlayerRootState();
}

class _SavePlayerRootState extends State<SavePlayerRoot> with RouteAware {
  late final SavePlayerViewModel _viewModel;
  String _title = '';
  late Widget _body;
  bool _showBackButton = false;
  Color? _appBarColor;
  String _currentPath = '';
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SavePlayerViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 현재 라우트와 함께 RouteObserver 등록
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      // 이전 구독 취소
      routeObserver.unsubscribe(this);
      // 새 구독 등록
      routeObserver.subscribe(this, modalRoute);
    }
    
    // 현재 URI에서 쿼리 파라미터 확인
    final routerState = GoRouterState.of(context);
    final queryParams = routerState.uri.queryParameters;
    final shouldRefresh = queryParams['refresh'] == 'true';
    
    debugPrint('SavePlayerRoot - didChangeDependencies: 쿼리 파라미터 refresh=${queryParams['refresh']}, 새로고침 필요=$shouldRefresh');
    
    _setupScreenContent();
    
    // 첫 로드 시 또는 refresh=true 쿼리 파라미터가 있을 때 데이터 갱신
    if (_firstLoad || shouldRefresh) {
      _firstLoad = false;
      _refreshAllData();
      
      // 쿼리 파라미터 제거를 위한 URL 업데이트 (새로고침 후에는 필요 없음)
      if (shouldRefresh) {
        // 쿼리 파라미터만 제거하고 현재 경로 유지
        Future.microtask(() {
          if(mounted){
            final currentLocation = routerState.matchedLocation;
            context.go(currentLocation);
          }
        });
      }
    }
  }
  
  @override
  void dispose() {
    // RouteObserver 구독 해제
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  
  // 화면이 다시 표시될 때 호출
  @override
  void didPopNext() {
    debugPrint('SavePlayerRoot - didPopNext: 화면이 다시 표시됨');
    _refreshAllData();
    
    // 다른 화면에서 돌아왔을 때 화면 내용도 업데이트
    if (mounted) {
      Future.microtask(() {
        setState(() {
          _setupScreenContent();
        });
      });
    }
  }

  // 이 화면이 다른 화면으로 가려질 때 호출
  @override
  void didPushNext() {
    debugPrint('SavePlayerRoot - didPushNext: 화면이 가려짐');
  }

  void _setupScreenContent() {
    // 현재 URL에서 마지막 경로 부분을 추출
    final routerState = GoRouterState.of(context);
    final location = routerState.matchedLocation;
    final queryParams = routerState.uri.queryParameters;
    
    // 쿼리 파라미터에서 refresh 여부 확인
    final shouldRefresh = queryParams['refresh'] == 'true';
    
    // 경로가 변경된 경우에만 처리
    final isPathChanged = _currentPath != location;
    _currentPath = location;

    // 경로 및 선택된 그룹 ID 로깅
    debugPrint(
      'SavePlayerRoot - 현재 경로: $location, 선택된 그룹 ID: ${_viewModel.state.selectedGroupId}, 경로 변경: $isPathChanged, 새로고침 필요: $shouldRefresh',
    );

    // 선택된 색상 계산 (기본값: 파란색)
    final selectedColor =
        _viewModel.state.selectedGroupColor != null
            ? Color(_viewModel.state.selectedGroupColor!)
            : Colors.blue;

    // 그룹 생성 화면 생성
    final createGroupRoot = CreateGroupRoot(
      isGroupNameValid: _viewModel.state.isGroupNameValid,
      selectedColor: selectedColor,
      onAction: (action) => _viewModel.onAction(action),
    );

    if (location.endsWith(RoutePaths.groupList) || location == RoutePaths.savePlayer) {
      // 그룹 목록 화면
      _title = '그룹 목록';
      
      // 데이터 새로고침이 필요한 경우:
      // 1. 홈에서 들어와서 refresh=true 쿼리 파라미터가 있는 경우
      // 2. 그룹 생성 화면에서 돌아온 경우
      // 3. 경로가 변경된 경우
      if (shouldRefresh || 
          (isPathChanged && (_currentPath.contains(RoutePaths.createGroup) || _currentPath.contains(RoutePaths.home)))) {
        debugPrint('SavePlayerRoot - 그룹 목록 화면으로 진입: 데이터 새로고침');
        _refreshAllData();
      }
      
      _body = GroupListRoot(
        groups: _viewModel.state.groups,
        viewModel: _viewModel,
      );
      _showBackButton = false;
      _appBarColor = null; // 그룹 목록에서는 기본 색상 사용
    } else if (location.contains('/group-detail/')) {
      // 그룹 상세 화면
      // URL에서 그룹 ID 추출 (URL 패턴: /save-player/group-detail/123)
      final pathSegments = location.split('/');
      final groupIdStr = pathSegments.length >= 4 ? pathSegments[3] : null;
      final groupId = int.tryParse(groupIdStr ?? '') ?? 0;

      debugPrint('SavePlayerRoot - 그룹 상세 화면: 추출된 그룹 ID: $groupId');

      // 그룹 정보 가져오기 및 색상 설정
      _loadGroupColor(groupId);

      // 위젯을 미리 생성
      _title = '그룹 상세';
      _body = GroupDetailRoot(
        groupId: groupId,
        getGroupById: _viewModel.getGroupById,
        getPlayersInGroup: _viewModel.getPlayersInGroup,
        onAction: _viewModel.onAction,
      );
      _showBackButton = true;
    } else if (location.endsWith(RoutePaths.createGroup)) {
      _title = '그룹 생성';
      _body = createGroupRoot;
      _showBackButton = true;
      _appBarColor = null; // 그룹 생성 화면에서는 기본 색상 사용
    } else {
      // 기본 화면 (그룹 목록)
      _title = '그룹 목록';
      _body = GroupListRoot(
        groups: _viewModel.state.groups,
        viewModel: _viewModel,
      );
      _showBackButton = false;
      _appBarColor = null; // 기본 화면에서는 기본 색상 사용
    }
  }

  // 모든 데이터 새로고침
  void _refreshAllData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.refreshAllData();
    });
  }

  // 그룹 색상 로드
  void _loadGroupColor(int groupId) async {
    try {
      final group = await _viewModel.getGroupById(groupId);
      if (group != null && mounted) {
        setState(() {
          // 그룹에 색상이 있으면 사용하고, 없으면 기본 앱 색상 사용
          if (group.color != null) {
            _appBarColor = group.color;
            debugPrint('SavePlayerRoot - 그룹 ${group.name}의 색상 ${group.color}를 앱바에 적용합니다.');
          } else {
            debugPrint('SavePlayerRoot - 그룹 ${group.name}에 색상이 없어서 기본 색상을 사용합니다.');
            _appBarColor = null;
          }
        });
      } else {
        debugPrint('SavePlayerRoot - 그룹을 찾을 수 없거나 위젯이 마운트 해제되었습니다.');
      }
    } catch (e) {
      debugPrint('SavePlayerRoot - 그룹 색상 로드 실패: $e');
      // 오류 발생 시 기본 색상으로 폴백
      if (mounted) {
        setState(() {
          _appBarColor = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        // 화면 구성 로그
        debugPrint(
          'SavePlayerRoot.build - 선택된 그룹 ID: ${_viewModel.state.selectedGroupId}, 그룹 수: ${_viewModel.state.groups.length}',
        );

        // UI가 변경될 때마다 화면 내용 재설정
        _setupScreenContent();

        return SavePlayerScreen(
          title: _title,
          body: _body,
          showBackButton: _showBackButton,
          appBarColor: _appBarColor,
        );
      },
    );
  }
}
