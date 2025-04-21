import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
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

class _CreateTournamentRootState extends State<CreateTournamentRoot> {
  late CreateTournamentViewModel viewModel;
  String currentLocation = ''; // 현재 경로를 저장할 변수 추가

  @override
  void initState() {
    super.initState();

    // 기존에 등록된 뷰모델이 있다면 재사용, 없으면 새로 생성
    if (getIt.isRegistered<CreateTournamentViewModel>()) {
      debugPrint(
        'CreateTournamentRoot - initState: 기존 CreateTournamentViewModel 재사용',
      );
      viewModel = getIt<CreateTournamentViewModel>();
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
      debugPrint(
        'CreateTournamentRoot - initState: 새로운 CreateTournamentViewModel 등록됨',
      );
    }
  }

  // 위젯 의존성이 변경될 때 현재 위치를 안전하게 저장
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      // 이 시점에서는 context가 유효하므로 현재 경로를 안전하게 저장
      currentLocation = GoRouterState.of(context).matchedLocation;
      debugPrint(
        'CreateTournamentRoot - didChangeDependencies: 현재 경로 $currentLocation',
      );
    } catch (e) {
      debugPrint('CreateTournamentRoot - didChangeDependencies 오류: $e');
    }
  }

  @override
  void dispose() {
    // 뷰모델은 앱 종료 시나 다른 화면으로 완전히 벗어날 때만 제거하도록 수정
    // 안전하게 뷰모델 정보 출력
    if (getIt.isRegistered<CreateTournamentViewModel>()) {
      debugPrint('CreateTournamentRoot - dispose: 뷰모델 정보 출력');
      debugPrint('선수 목록 수: ${viewModel.state.players.length}');
      if (viewModel.state.players.isNotEmpty) {
        debugPrint(
          '선수 목록: ${viewModel.state.players.map((p) => "${p.id}:${p.name}").join(', ')}',
        );
      }

      // 완전히 앱이 종료될 때 getIt 싱글톤만 제거
      // GoRouterState에 접근하지 않음
      debugPrint('CreateTournamentRoot - dispose: 화면 종료, 뷰모델 유지');
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
        );
      },
    );
  }
}
