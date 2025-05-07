import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

/// 파트너 검증 관련 경고를 표시하는 배너 위젯
class PartnerWarningBanner extends StatelessWidget {
  final String message;
  final bool isPlayerCountWarning;
  final int currentCount;
  final int requiredCount;
  
  const PartnerWarningBanner({
    super.key,
    required this.message,
    required this.isPlayerCountWarning,
    required this.currentCount,
    required this.requiredCount,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: CST.primary20,
      child: Row(
        children: [
          Icon(
            isPlayerCountWarning
                ? currentCount < requiredCount
                    ? Icons.error_outline
                    : Icons.warning_amber_outlined
                : Icons.info_outline,
            color: isPlayerCountWarning
                ? currentCount < requiredCount
                    ? CST.error
                    : Colors.orange
                : CST.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TST.smallTextBold.copyWith(
                color: isPlayerCountWarning
                    ? currentCount < requiredCount
                        ? CST.error
                        : Colors.orange
                    : CST.error,
              ),
            ),
          ),
          Text(
            isPlayerCountWarning
                ? "$currentCount/$requiredCount명"
                : "$currentCount/$requiredCount쌍",
            style: TST.smallTextBold.copyWith(
              color: isPlayerCountWarning
                  ? currentCount < requiredCount
                      ? CST.error
                      : currentCount > 32
                          ? Colors.orange
                          : CST.error
                  : CST.error,
            ),
          ),
        ],
      ),
    );
  }
} 