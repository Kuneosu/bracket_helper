import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
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

class _SavePlayerRootState extends State<SavePlayerRoot> {
  late final SavePlayerViewModel _viewModel;
  String _title = '';
  late Widget _body;
  bool _showBackButton = false;
  Color? _appBarColor;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SavePlayerViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupScreenContent();
  }

  void _setupScreenContent() {
    // 현재 URL에서 마지막 경로 부분을 추출
    final location = GoRouterState.of(context).matchedLocation;

    // 경로 및 선택된 그룹 ID 로깅
    debugPrint(
      'SavePlayerRoot - 현재 경로: $location, 선택된 그룹 ID: ${_viewModel.state.selectedGroupId}',
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

    if (location.endsWith(RoutePaths.groupList)) {
      _title = '그룹 목록';
      _body = GroupListRoot(
        groups: _viewModel.state.groups,
        viewModel: _viewModel,
      );
      _showBackButton = false;
      _appBarColor = null; // 그룹 목록에서는 기본 색상 사용
    } else if (location.contains('group-detail')) {
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
