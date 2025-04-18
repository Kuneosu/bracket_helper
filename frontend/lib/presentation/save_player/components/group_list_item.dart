import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class GroupListItem extends StatefulWidget {
  final GroupModel group;
  final int playerCount;
  final void Function() onTap;
  final void Function() onRemoveTap;
  final void Function(String)? onRename;
  final void Function(Color)? onUpdateColor;
  final bool isEditMode;

  const GroupListItem({
    super.key,
    required this.group,
    required this.playerCount,
    required this.onTap,
    required this.onRemoveTap,
    this.onRename,
    this.onUpdateColor,
    this.isEditMode = false,
  });

  @override
  State<GroupListItem> createState() => _GroupListItemState();
}

class _GroupListItemState extends State<GroupListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _nameController.text = widget.group.name;
  }

  @override
  void didUpdateWidget(GroupListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.name != widget.group.name) {
      _nameController.text = widget.group.name;
    }

    // 편집 모드가 종료될 때 이름 변경 적용 - microtask를 사용하여 빌드 중에 UI 업데이트 방지
    if (oldWidget.isEditMode && !widget.isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndApplyNameChange();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  // 이름 변경 확인 및 적용
  void _checkAndApplyNameChange() {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isNotEmpty &&
        trimmedName != widget.group.name &&
        widget.onRename != null) {
      widget.onRename!(trimmedName);
    }
  }

  // 이름 변경이 완료될 때 호출
  void _onRenameComplete() {
    _checkAndApplyNameChange();
    _nameFocusNode.unfocus();
  }

  // 그룹 삭제 확인 다이얼로그 표시
  void _showDeleteConfirmation(BuildContext context) {
    // 빌드 단계에서 호출될 경우를 대비해 microtask로 지연시켜 실행
    Future.microtask(() {
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder:
            (dialogContext) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CST.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CST.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단 아이콘
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CST.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: CST.error,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 제목
                    Text(
                      '그룹 삭제',
                      style: TST.normalTextBold.copyWith(color: CST.gray1),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),

                    // 내용
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TST.smallTextRegular.copyWith(color: CST.gray2),
                        children: [
                          TextSpan(
                            text: '"${widget.group.name}" ',
                            style: TST.smallTextBold.copyWith(color: CST.error),
                          ),
                          const TextSpan(text: '그룹을 삭제하시겠습니까?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 경고 메시지
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CST.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: CST.error,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '이 작업은 되돌릴 수 없으며 그룹 내 모든 연결 정보가 삭제됩니다.',
                              style: TST.smallerTextRegular.copyWith(
                                color: CST.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 취소 버튼
                        ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: CST.gray2,
                            backgroundColor: CST.gray4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: TST.smallTextBold.copyWith(color: CST.gray1),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 삭제 버튼
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            // 삭제 액션 호출
                            widget.onRemoveTap();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: CST.white,
                            backgroundColor: CST.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            '삭제',
                            style: TST.smallTextBold.copyWith(color: CST.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      );
    });
  }

  // 색상 선택 다이얼로그 표시
  void _showColorPickerDialog(BuildContext context) {
    // 현재 그룹 색상
    Color selectedColor = widget.group.color ?? CST.primary60;

    // 빌드 단계에서 호출될 경우를 대비해 microtask로 지연시켜 실행
    Future.microtask(() {
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder:
            (dialogContext) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: StatefulBuilder(
                builder:
                    (context, setState) => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CST.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: CST.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 상단 아이콘
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.color_lens,
                              color: selectedColor,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // 제목
                          Text(
                            '그룹 색상 변경',
                            style: TST.normalTextBold.copyWith(
                              color: CST.gray1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),

                          // 색상 선택 영역
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              // 기본 색상 목록
                              _buildColorOption(CST.primary100, selectedColor, (
                                color,
                              ) {
                                setState(() => selectedColor = color);
                              }),
                              _buildColorOption(CST.primary80, selectedColor, (
                                color,
                              ) {
                                setState(() => selectedColor = color);
                              }),
                              _buildColorOption(CST.primary60, selectedColor, (
                                color,
                              ) {
                                setState(() => selectedColor = color);
                              }),
                              _buildColorOption(
                                CST.secondary100,
                                selectedColor,
                                (color) {
                                  setState(() => selectedColor = color);
                                },
                              ),
                              _buildColorOption(
                                CST.secondary80,
                                selectedColor,
                                (color) {
                                  setState(() => selectedColor = color);
                                },
                              ),
                              _buildColorOption(
                                CST.secondary60,
                                selectedColor,
                                (color) {
                                  setState(() => selectedColor = color);
                                },
                              ),
                              _buildColorOption(Colors.purple, selectedColor, (
                                color,
                              ) {
                                setState(() => selectedColor = color);
                              }),
                              _buildColorOption(Colors.teal, selectedColor, (
                                color,
                              ) {
                                setState(() => selectedColor = color);
                              }),
                              _buildColorOption(Colors.green, selectedColor, (
                                color,
                              ) {
                                setState(() => selectedColor = color);
                              }),
                              _buildColorOption(Colors.red, selectedColor, (
                                color,
                              ) {
                                setState(() => selectedColor = color);
                              }),
                              _buildColorOption(
                                Colors.deepOrange,
                                selectedColor,
                                (color) {
                                  setState(() => selectedColor = color);
                                },
                              ),
                              _buildColorOption(Colors.brown, selectedColor, (
                                color,
                              ) {
                                setState(() => selectedColor = color);
                              }),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // 버튼
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 취소 버튼
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.of(dialogContext).pop(),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: CST.gray2,
                                  backgroundColor: CST.gray4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text(
                                  '취소',
                                  style: TST.smallTextBold.copyWith(
                                    color: CST.gray1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // 변경 버튼
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  // 색상 변경 액션 호출
                                  if (widget.onUpdateColor != null) {
                                    widget.onUpdateColor!(selectedColor);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: CST.white,
                                  backgroundColor: selectedColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text(
                                  '변경',
                                  style: TST.smallTextBold.copyWith(
                                    color: CST.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              ),
            ),
      );
    });
  }

  // 색상 선택 옵션 위젯
  Widget _buildColorOption(
    Color color,
    Color selectedColor,
    Function(Color) onSelect,
  ) {
    final bool isSelected = color.toARGB32() == selectedColor.toARGB32();

    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: isSelected ? 8 : 3,
              spreadRadius: isSelected ? 1 : 0,
            ),
          ],
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildCardContent(),
        );
      },
    );
  }

  Widget _buildCardContent() {
    final Color groupColor = widget.group.color ?? CST.primary60;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isEditMode ? null : widget.onTap, // 편집 모드에서는 탭 동작 비활성화
        onTapDown: (_) {
          if (!widget.isEditMode) {
            _controller.forward();
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) {
          if (!widget.isEditMode) {
            _controller.reverse();
            setState(() => _isPressed = false);
          }
        },
        onTapCancel: () {
          if (!widget.isEditMode) {
            _controller.reverse();
            setState(() => _isPressed = false);
          }
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: groupColor.withValues(alpha: 0.1),
        highlightColor: groupColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Ink(
            decoration: BoxDecoration(
              color: CST.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: CST.black.withValues(alpha: _isPressed ? 0.05 : 0.1),
                  blurRadius: _isPressed ? 6 : 8,
                  spreadRadius: _isPressed ? 0 : 2,
                  offset: Offset(0, _isPressed ? 1 : 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  // 그룹 색상 원형 표시
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(15),
                    child: InkWell(
                      onTap:
                          widget.isEditMode && widget.onUpdateColor != null
                              ? () => _showColorPickerDialog(context)
                              : null,
                      customBorder: const CircleBorder(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: groupColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: groupColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child:
                            widget.isEditMode && widget.onUpdateColor != null
                                ? Center(
                                  child: Icon(
                                    Icons.color_lens,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    size: 20,
                                  ),
                                )
                                : null,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 그룹 이름 - 편집 모드에서는 텍스트 필드로 변경
                  Expanded(
                    child:
                        widget.isEditMode
                            ? InkWell(
                              onTap: () {
                                // 포커스 설정하여 키보드 표시
                                _nameFocusNode.requestFocus();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: CST.primary60),
                                  borderRadius: BorderRadius.circular(8),
                                  color: CST.primary20,
                                ),
                                child: TextField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  style: TST.mediumTextBold.copyWith(
                                    color: CST.primary100,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onEditingComplete: _onRenameComplete,
                                ),
                              ),
                            )
                            : Text(
                              widget.group.name,
                              style: TST.mediumTextBold,
                              overflow: TextOverflow.ellipsis,
                            ),
                  ),

                  const SizedBox(width: 12),

                  // 편집 모드일 때 제거 버튼, 아닐 때 플레이어 수 표시
                  widget.isEditMode
                      ? Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: DefaultButton(
                          text: '제거',
                          onTap: () {
                            _showDeleteConfirmation(context);
                          },
                          color: CST.error,
                          width: 60,
                          height: 36,
                          textStyle: TST.smallTextBold,
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildPlayerCountBadge(),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCountBadge() {
    debugPrint(
      'GroupListItem: 그룹 ${widget.group.id}(${widget.group.name}) - 선수 수: ${widget.playerCount}명 표시',
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CST.gray4.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, size: 18, color: CST.gray2),
          const SizedBox(width: 6),
          Text(
            widget.playerCount.toString(),
            style: TST.smallTextBold.copyWith(color: CST.gray2),
          ),
        ],
      ),
    );
  }
}
