import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class SquareIconMenu extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double imageSize;
  
  /// 직사각형 형태의 아이콘 메뉴 버튼
  ///
  /// [title] 버튼 텍스트
  /// [imagePath] 이미지 경로
  /// [onTap] 탭 이벤트 핸들러
  /// [width] 버튼 너비 (기본값: 180)
  /// [height] 버튼 높이 (기본값: 90)
  /// [imageSize] 이미지 크기 (기본값: 50)
  const SquareIconMenu({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.width = 180,
    this.height = 90,
    this.imageSize = 50,
  });

  @override
  State<SquareIconMenu> createState() => _SquareIconMenuState();
}

class _SquareIconMenuState extends State<SquareIconMenu> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: CST.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CST.black.withValues(alpha: _isPressed ? 0.05 : 0.1),
                blurRadius: _isPressed ? 4 : 6,
                spreadRadius: _isPressed ? 1 : 2,
                offset: const Offset(0, 0),
              ),
            ],
            border: _isPressed
                ? Border.all(color: CST.primary20, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  widget.imagePath, 
                  width: widget.imageSize, 
                  height: widget.imageSize,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title, 
                    style: TST.normalTextBold.copyWith(
                      color: _isPressed ? CST.primary100 : CST.gray1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
