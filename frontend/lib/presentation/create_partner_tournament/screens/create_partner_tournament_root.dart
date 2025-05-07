import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/delete_match_by_tournament_id_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/create_match_use_case.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_action.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/screens/create_partner_tournament_screen.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/screens/partner_add_player/partner_add_player_root.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/screens/partner_edit_match/partner_edit_match_root.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/screens/partner_tournament_info/partner_tournament_info_root.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePartnerTournamentRoot extends StatefulWidget {
  const CreatePartnerTournamentRoot({super.key});

  @override
  State<CreatePartnerTournamentRoot> createState() =>
      _CreatePartnerTournamentRootState();
}

class _CreatePartnerTournamentRootState
    extends State<CreatePartnerTournamentRoot>
    with WidgetsBindingObserver {
  late CreatePartnerTournamentViewModel viewModel;
  String currentLocation = ''; // 현재 경로를 저장할 변수 추가

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 로깅
    debugPrint(
      'CreatePartnerTournamentRoot - initState 시작: SingletonRegistry에 CreatePartnerTournamentViewModel이 있는지 확인',
    );

    // 기존에 등록된 뷰모델이 있다면 재사용, 없으면 새로 생성
    if (getIt.isRegistered<CreatePartnerTournamentViewModel>()) {
      debugPrint(
        'CreatePartnerTournamentRoot - initState: 기존 CreatePartnerTournamentViewModel 재사용',
      );
      viewModel = getIt<CreatePartnerTournamentViewModel>();

      // 현재 상태 로깅
      debugPrint(
        'CreatePartnerTournamentRoot - 현재 상태: 선수 ${viewModel.state.players.length}명, 그룹 ${viewModel.state.groups.length}개',
      );

      // 재사용 시에도 그룹 데이터 로드를 항상 시도
      // 사용자가 다시 돌아왔을 때 최신 데이터를 보여주기 위함
      debugPrint('CreatePartnerTournamentRoot - 그룹 데이터 새로고침 시작');

      // 화면이 완전히 빌드된 후에 그룹 데이터 로드 (UI 블로킹 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.onAction(
          const CreatePartnerTournamentAction.fetchAllGroups(),
        );
      });
    } else {
      // 뷰모델 생성 및 등록
      debugPrint(
        'CreatePartnerTournamentRoot - initState: 새로운 CreatePartnerTournamentViewModel 생성',
      );
      viewModel = CreatePartnerTournamentViewModel(
        getIt<CreateTournamentUseCase>(),
        getIt<GetAllGroupsUseCase>(),
        getIt<GetGroupUseCase>(),
        getIt<CreateMatchUseCase>(),
        getIt<DeleteMatchByTournamentIdUseCase>(),
      );
      getIt.registerSingleton<CreatePartnerTournamentViewModel>(viewModel);

      // 화면이 완전히 빌드된 후에 그룹 데이터 로드 (UI 블로킹 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('CreatePartnerTournamentRoot - 그룹 데이터 로드 시작 (초기화)');
        viewModel.onAction(
          const CreatePartnerTournamentAction.fetchAllGroups(),
        );
      });

      debugPrint(
        'CreatePartnerTournamentRoot - initState: 새로운 CreatePartnerTournamentViewModel 등록됨',
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
          if (!currentPath.contains(RoutePaths.createPartnerTournament)) {
            // 비동기로 실행하여 프레임워크 락 상태에서 빌드하는 것 방지
            debugPrint(
              'didChangeAppLifecycleState - 대회 생성이 아닌 경로로 돌아옴: $currentPath',
            );
            Future.microtask(() => _cleanupViewModel());
          } else {
            // CreatePartnerTournament 화면 내에서 돌아온 경우에는 상태 유지
            debugPrint(
              'didChangeAppLifecycleState - 대회 생성 화면으로 돌아옴: $currentPath',
            );
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
        'CreatePartnerTournamentRoot - didChangeDependencies: 현재 경로 $currentLocation, 이전 경로 $prevLocation',
      );

      // extra 데이터 확인 (대진 수정 모드)
      final state = GoRouterState.of(context);
      final extra = state.extra;

      // shouldReset 파라미터 확인 (홈 화면에서 넘어올 때)
      if (extra != null &&
          extra is Map<String, dynamic> &&
          extra.containsKey('shouldReset')) {
        final shouldReset = extra['shouldReset'] as bool;

        if (shouldReset) {
          debugPrint(
            'CreatePartnerTournamentRoot - shouldReset 파라미터가 true, ViewModel 초기화',
          );

          // 뷰모델 상태 초기화
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.resetState();
          });
        }
      }

      // 대진표 수정 모드로 접근한 경우 (MatchScreen에서 이동)
      if (extra != null &&
          extra is Map<String, dynamic> &&
          currentLocation.endsWith(RoutePaths.partnerEditMatch)) {
        debugPrint('CreatePartnerTournamentRoot - 대진 수정 모드로 접근: $extra');

        // 데이터 추출
        final tournament = extra['tournament'];
        final players = extra['players'];
        final matches = extra['matches'];

        if (tournament != null && players != null && matches != null) {
          debugPrint('CreatePartnerTournamentRoot - 대진 수정 데이터 초기화 시작');

          // 뷰모델 상태 초기화 (이미 초기화되지 않은 경우에만)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state.tournament.id != tournament.id) {
              debugPrint('CreatePartnerTournamentRoot - 뷰모델 상태 초기화');
              viewModel.initializeFromExisting(
                tournament: tournament,
                players: players,
                matches: matches,
              );
            }
          });
        }
      }

      // 대회 생성 프로세스 내부 이동은 무시하고, 완전히 다른 경로로 이동한 경우에만 뷰모델 정리
      if (prevLocation.isNotEmpty &&
          prevLocation.contains(RoutePaths.createPartnerTournament) &&
          !currentLocation.contains(RoutePaths.createPartnerTournament)) {
        // 대회 생성 화면을 완전히 벗어난 경우에만 뷰모델 정리
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _cleanupViewModel();
        });
      } else if (prevLocation.isNotEmpty &&
          prevLocation.contains(RoutePaths.createPartnerTournament) &&
          currentLocation.contains(RoutePaths.createPartnerTournament)) {
        // 대회 생성 프로세스 내 이동인 경우 로그만 출력
        debugPrint(
          'CreatePartnerTournamentRoot - 대회 생성 프로세스 내 화면 이동: $prevLocation -> $currentLocation',
        );

        // 이동 시 필요한 데이터가 있는지 확인하고 강제 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.state.groups.isEmpty) {
            debugPrint('CreatePartnerTournamentRoot - 그룹 데이터 없음, 강제 로드');
            viewModel.onAction(
              const CreatePartnerTournamentAction.fetchAllGroups(),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('CreatePartnerTournamentRoot - didChangeDependencies 오류: $e');
    }
  }

  // 뷰모델 정리 함수
  void _cleanupViewModel() {
    if (getIt.isRegistered<CreatePartnerTournamentViewModel>()) {
      debugPrint('CreatePartnerTournamentRoot - 대회 생성 과정 완전히 종료: 뷰모델 제거');

      try {
        // 뷰모델 상태 로깅 (디버깅용)
        debugPrint(
          'CreatePartnerTournamentRoot - 정리 전 상태: 선수 ${viewModel.state.players.length}명, 그룹 ${viewModel.state.groups.length}개',
        );

        // 싱글톤에서 제거 (다음에 화면 진입 시 새로 생성되도록)
        getIt.unregister<CreatePartnerTournamentViewModel>();

        debugPrint('CreatePartnerTournamentRoot - 뷰모델 제거 완료');
      } catch (e) {
        debugPrint('CreatePartnerTournamentRoot - 뷰모델 정리 중 오류 발생: $e');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // 저장된 currentLocation을 사용하여 뷰모델 정리 여부 결정
    try {
      // 현재 저장된 경로 사용 (GoRouterState.of(context) 호출 대신)
      if (!currentLocation.contains(RoutePaths.createPartnerTournament)) {
        debugPrint(
          'CreatePartnerTournamentRoot - dispose: 대회 생성 프로세스 외부로 이동 ($currentLocation), 뷰모델 정리',
        );
        _cleanupViewModel();
      } else {
        debugPrint(
          'CreatePartnerTournamentRoot - dispose: 대회 생성 프로세스 내부에서 종료 ($currentLocation), 뷰모델 유지',
        );
      }
    } catch (e) {
      debugPrint('CreatePartnerTournamentRoot - dispose 중 오류: $e');
      // 오류 발생 시 안전하게 뷰모델 정리
      _cleanupViewModel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentPageIndex = 0;

    if (location.endsWith(RoutePaths.partnerTournamentInfo) ||
        location == RoutePaths.createPartnerTournament) {
      currentPageIndex = 0;
    } else if (location.endsWith(RoutePaths.partnerAddPlayer)) {
      currentPageIndex = 1;
    } else if (location.endsWith(RoutePaths.partnerEditMatch)) {
      currentPageIndex = 2;
    }

    debugPrint(
      'CreatePartnerTournamentRoot - build: 현재 경로 $location, 페이지 인덱스 $currentPageIndex',
    );
    debugPrint('현재 선수 목록 수: ${viewModel.state.players.length}');

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        debugPrint(
          'CreatePartnerTournamentRoot - ListenableBuilder 호출: 현재 선수 수 ${viewModel.state.players.length}명',
        );

        final body = switch (currentPageIndex) {
          0 => PartnerTournamentInfoRoot(viewModel: viewModel),
          1 => PartnerAddPlayerRoot(viewModel: viewModel),
          2 => PartnerEditMatchRoot(viewModel: viewModel),
          _ => PartnerTournamentInfoRoot(viewModel: viewModel),
        };

        debugPrint(
          'CreatePartnerTournamentRoot - 페이지 전환: 인덱스 $currentPageIndex',
        );
        return CreatePartnerTournamentScreen(
          body: body,
          currentPageIndex: currentPageIndex,
          onExit: () {
            // 대회 생성 종료 시 호출되는 콜백
            debugPrint('CreatePartnerTournamentRoot - 종료 콜백 호출됨');
            viewModel.onAction(const CreatePartnerTournamentAction.onDiscard());
          },
        );
      },
    );
  }
}
