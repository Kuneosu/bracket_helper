import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

/// 대회 생성 과정의 하단 네비게이션 버튼 위젯
/// 이전/다음 버튼을 포함합니다.
class NavigationButtonsWidget extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final String? previousText;
  final String? nextText;
  final bool isNextDisabled;
  final IconData? previousIcon;
  final IconData? nextIcon;
  final double textScaleFactor;

  const NavigationButtonsWidget({
    super.key,
    required this.onPrevious,
    required this.onNext,
    this.previousText,
    this.nextText,
    this.isNextDisabled = false,
    this.previousIcon = Icons.arrow_back_rounded,
    this.nextIcon = Icons.arrow_forward_rounded,
    this.textScaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final previousText = this.previousText ?? AppStrings.previous;
    final nextText = this.nextText ?? AppStrings.next;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // 이전 버튼
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: onPrevious,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CST.primary100, width: 2),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (previousIcon != null)
                      Icon(
                        previousIcon,
                        color: CST.primary100,
                        size: 20,
                      ),
                    if (previousIcon != null)
                      const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        previousText,
                        style: TST.mediumTextBold.copyWith(
                          color: CST.primary100,
                          fontSize: TST.mediumTextBold.fontSize! * textScaleFactor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // 다음 버튼
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: isNextDisabled ? null : onNext,
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: isNextDisabled ? 0.6 : 1.0,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isNextDisabled ? CST.gray3 : CST.primary100,
                    boxShadow: isNextDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: CST.primary100.withValues(
                                alpha: 0.3,
                              ),
                              spreadRadius: 0,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            nextText,
                            style: TST.mediumTextBold.copyWith(
                              color: Colors.white,
                              fontSize: TST.mediumTextBold.fontSize! * textScaleFactor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (nextIcon != null)
                        const SizedBox(width: 4),
                      if (nextIcon != null)
                        Icon(
                          nextIcon,
                          color: Colors.white,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 