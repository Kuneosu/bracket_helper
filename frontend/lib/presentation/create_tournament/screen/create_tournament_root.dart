import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/add_player/add_player_root.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/create_tournament_screen.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/edit_match/edit_match_root.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/tournament_info/tournament_info_root.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateTournamentRoot extends StatefulWidget {
  const CreateTournamentRoot({super.key});

  @override
  State<CreateTournamentRoot> createState() => _CreateTournamentRootState();
}

class _CreateTournamentRootState extends State<CreateTournamentRoot> with WidgetsBindingObserver {
  late CreateTournamentViewModel viewModel;
  String currentLocation = ''; // 현재 경로를 저장할 변수 추가

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 로깅
    debugPrint(
      'CreateTournamentRoot - initState 시작: SingletonRegistry에 CreateTournamentViewModel이 있는지 확인',
    );

    // 기존에 등록된 뷰모델이 있다면 재사용, 없으면 새로 생성
    if (getIt.isRegistered<CreateTournamentViewModel>()) {
      debugPrint(
        'CreateTournamentRoot - initState: 기존 CreateTournamentViewModel 재사용',
      );
      viewModel = getIt<CreateTournamentViewModel>();
      
      // 현재 상태 로깅
      debugPrint(
        'CreateTournamentRoot - 현재 상태: 선수 ${viewModel.state.players.length}명, 그룹 ${viewModel.state.groups.length}개',
      );
      
      // 재사용 시에도 그룹 데이터 로드를 항상 시도
      // 사용자가 다시 돌아왔을 때 최신 데이터를 보여주기 위함
      debugPrint('CreateTournamentRoot - 그룹 데이터 새로고침 시작');
      
      // 화면이 완전히 빌드된 후에 그룹 데이터 로드 (UI 블로킹 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.onAction(const CreateTournamentAction.fetchAllGroups());
      });
    } else {
      // 뷰모델 생성 및 등록
      debugPrint(
        'CreateTournamentRoot - initState: 새로운 CreateTournamentViewModel 생성',
      );
      viewModel = CreateTournamentViewModel(
        getIt<CreateTournamentUseCase>(),
        getIt<GetAllGroupsUseCase>(),
        getIt<GetGroupUseCase>(),
      );
      getIt.registerSingleton<CreateTournamentViewModel>(viewModel);
      
      // 화면이 완전히 빌드된 후에 그룹 데이터 로드 (UI 블로킹 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('CreateTournamentRoot - 그룹 데이터 로드 시작 (초기화)');
        viewModel.onAction(const CreateTournamentAction.fetchAllGroups());
      });
      
      debugPrint(
        'CreateTournamentRoot - initState: 새로운 CreateTournamentViewModel 등록됨',
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때 현재 경로를 확인
      try {
        // 라우트 상태 확인이 가능한 상태에서만 실행
        if (context.mounted) {
          final currentPath = GoRouterState.of(context).matchedLocation;
          
          // 완전히 다른 화면으로 이동한 경우에만 뷰모델 정리
          if (!currentPath.contains(RoutePaths.createTournament)) {
            // 비동기로 실행하여 프레임워크 락 상태에서 빌드하는 것 방지
            debugPrint('didChangeAppLifecycleState - 대회 생성이 아닌 경로로 돌아옴: $currentPath');
            Future.microtask(() => _cleanupViewModel());
          } else {
            // CreateTournament 화면 내에서 돌아온 경우에는 상태 유지
            debugPrint('didChangeAppLifecycleState - 대회 생성 화면으로 돌아옴: $currentPath');
            // 만약 필요하다면 여기서 데이터 새로고침 로직 추가 가능
          }
        }
      } catch (e) {
        debugPrint('didChangeAppLifecycleState 오류: $e');
      }
    }
  }

  // 라우트 변경 감지를 위한 메서드
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      // 이전 경로 저장
      final prevLocation = currentLocation;
      // 현재 경로 가져오기
      currentLocation = GoRouterState.of(context).matchedLocation;
      
      debugPrint(
        'CreateTournamentRoot - didChangeDependencies: 현재 경로 $currentLocation, 이전 경로 $prevLocation',
      );
      
      // 대회 생성 프로세스 내부 이동은 무시하고, 완전히 다른 경로로 이동한 경우에만 뷰모델 정리
      if (prevLocation.isNotEmpty && 
          prevLocation.contains(RoutePaths.createTournament) && 
          !currentLocation.contains(RoutePaths.createTournament)) {
        // 대회 생성 화면을 완전히 벗어난 경우에만 뷰모델 정리
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _cleanupViewModel();
        });
      } else if (prevLocation.isNotEmpty && 
                 prevLocation.contains(RoutePaths.createTournament) && 
                 currentLocation.contains(RoutePaths.createTournament)) {
        // 대회 생성 프로세스 내 이동인 경우 로그만 출력
        debugPrint('CreateTournamentRoot - 대회 생성 프로세스 내 화면 이동: $prevLocation -> $currentLocation');
        
        // 이동 시 필요한 데이터가 있는지 확인하고 강제 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.state.groups.isEmpty) {
            debugPrint('CreateTournamentRoot - 그룹 데이터 없음, 강제 로드');
            viewModel.onAction(const CreateTournamentAction.fetchAllGroups());
          }
        });
      }
    } catch (e) {
      debugPrint('CreateTournamentRoot - didChangeDependencies 오류: $e');
    }
  }

  // 뷰모델 정리 함수
  void _cleanupViewModel() {
    if (getIt.isRegistered<CreateTournamentViewModel>()) {
      debugPrint('CreateTournamentRoot - 대회 생성 과정 완전히 종료: 뷰모델 제거');
      
      try {
        // 뷰모델 상태 로깅 (디버깅용)
        debugPrint(
          'CreateTournamentRoot - 정리 전 상태: 선수 ${viewModel.state.players.length}명, 그룹 ${viewModel.state.groups.length}개',
        );
        
        // 싱글톤에서 제거 (다음에 화면 진입 시 새로 생성되도록)
        getIt.unregister<CreateTournamentViewModel>();
        
        debugPrint('CreateTournamentRoot - 뷰모델 제거 완료');
      } catch (e) {
        debugPrint('CreateTournamentRoot - 뷰모델 정리 중 오류 발생: $e');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    // 화면이 완전히 제거될 때는 현재 경로 확인하여 조건부로 뷰모델 정리
    try {
      // 현재 경로 확인 방법
      final currentPath = GoRouterState.of(context).matchedLocation;
      
      // 대회 생성 경로가 아닌 곳으로 이동했을 때만 뷰모델 정리
      if (!currentPath.contains(RoutePaths.createTournament)) {
        debugPrint(
          'CreateTournamentRoot - dispose: 대회 생성 프로세스 외부로 이동 ($currentPath), 뷰모델 정리',
        );
        _cleanupViewModel();
      } else {
        debugPrint(
          'CreateTournamentRoot - dispose: 대회 생성 프로세스 내부에서 종료 ($currentPath), 뷰모델 유지',
        );
      }
    } catch (e) {
      debugPrint('CreateTournamentRoot - dispose 중 오류: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentPageIndex = 0;

    if (location.endsWith(RoutePaths.tournamentInfo) ||
        location == RoutePaths.createTournament) {
      currentPageIndex = 0;
    } else if (location.endsWith(RoutePaths.addPlayer)) {
      currentPageIndex = 1;
    } else if (location.endsWith(RoutePaths.editMatch)) {
      currentPageIndex = 2;
    }

    debugPrint(
      'CreateTournamentRoot - build: 현재 경로 $location, 페이지 인덱스 $currentPageIndex',
    );
    debugPrint('현재 선수 목록 수: ${viewModel.state.players.length}');

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        debugPrint(
          'CreateTournamentRoot - ListenableBuilder 호출: 현재 선수 수 ${viewModel.state.players.length}명',
        );

        final body = switch (currentPageIndex) {
          0 => TournamentInfoRoot(viewModel: viewModel),
          1 => AddPlayerRoot(viewModel: viewModel),
          2 => EditMatchRoot(viewModel: viewModel),
          _ => TournamentInfoRoot(viewModel: viewModel),
        };

        debugPrint('CreateTournamentRoot - 페이지 전환: 인덱스 $currentPageIndex');
        return CreateTournamentScreen(
          body: body,
          currentPageIndex: currentPageIndex,
          onExit: () {
            // 대회 생성 종료 시 호출되는 콜백
            debugPrint('CreateTournamentRoot - 종료 콜백 호출됨');
            viewModel.onAction(const CreateTournamentAction.onDiscard());
          },
        );
      },
    );
  }
}
