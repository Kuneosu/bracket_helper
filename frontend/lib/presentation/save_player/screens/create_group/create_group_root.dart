import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/screens/create_group/create_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGroupRoot extends StatefulWidget {
  final bool isGroupNameValid;
  final Color selectedColor;
  final Function(SavePlayerAction) onAction;

  const CreateGroupRoot({
    super.key,
    required this.isGroupNameValid,
    required this.selectedColor,
    required this.onAction,
  });

  @override
  State<CreateGroupRoot> createState() => _CreateGroupRootState();
}

class _CreateGroupRootState extends State<CreateGroupRoot> {
  // 항상 내부에서 컨트롤러 생성 및 관리
  late final TextEditingController _controller;
  bool _isCreatingGroup = false; // 그룹 생성 중 상태 관리

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // 이벤트 리스너 추가
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 이벤트 리스너 제거 및 컨트롤러 해제
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  // 텍스트 변경 이벤트 핸들러
  void _onTextChanged() {
    final text = _controller.text;
    widget.onAction(SavePlayerAction.onGroupNameChanged(text));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CreateGroupRoot.build - isFormValid: ${widget.isGroupNameValid}, isCreatingGroup: $_isCreatingGroup');
    
    return PopScope(
      // 생성 중에는 뒤로가기 방지
      canPop: !_isCreatingGroup,
      child: CreateGroupScreen(
        groupNameController: _controller,
        isFormValid: widget.isGroupNameValid && !_isCreatingGroup, // 생성 중에는 버튼 비활성화
        selectedColor: widget.selectedColor,
        onAction: _handleAction,
      ),
    );
  }
  
  // 액션 처리 메서드
  void _handleAction(SavePlayerAction action) async {
    debugPrint('CreateGroupRoot - 액션 수신: $action');
    
    // SaveGroup 액션은 네비게이션 처리 후 상위로 전달
    if (action is OnSaveGroup) {
      // 중복 저장 방지
      if (_isCreatingGroup) {
        debugPrint('CreateGroupRoot - 이미 그룹 생성 중, 중복 요청 무시');
        return;
      }
      
      setState(() {
        _isCreatingGroup = true; // 생성 중 상태로 변경
      });
      
      try {
        // 먼저 액션 전달 (그룹 생성)
        widget.onAction(action);
        
        // 약간의 지연 후 그룹 목록 화면으로 이동
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        debugPrint('CreateGroupRoot - 그룹 생성 완료 후 그룹 목록 화면으로 이동');
        
        // 그룹 목록 화면으로 이동 (pushReplacement 사용)
        context.pushReplacement('${RoutePaths.savePlayer}${RoutePaths.groupList}');
      } catch (e) {
        debugPrint('CreateGroupRoot - 그룹 생성 중 오류 발생: $e');
      } finally {
        // 상태 초기화 (실패하더라도)
        if (mounted) {
          setState(() {
            _isCreatingGroup = false;
          });
        }
      }
      return;
    }
    
    // 그 외 액션은 상위 컴포넌트로 전달
    widget.onAction(action);
  }
}
