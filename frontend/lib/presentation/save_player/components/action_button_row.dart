import 'package:flutter/material.dart';

class ActionButtonRow extends StatelessWidget {
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;
  final bool isConfirmEnabled;
  final EdgeInsetsGeometry padding;

  /// 액션 버튼 행 컴포넌트 (취소, 확인 버튼이 포함된 행)
  ///
  /// [cancelText] 취소 버튼 텍스트
  /// [confirmText] 확인 버튼 텍스트
  /// [onCancel] 취소 버튼 클릭 시 호출되는 콜백 함수
  /// [onConfirm] 확인 버튼 클릭 시 호출되는 콜백 함수
  /// [isConfirmEnabled] 확인 버튼 활성화 여부
  /// [padding] 버튼의 패딩 (기본값: vertical 16)
  const ActionButtonRow({
    super.key,
    this.cancelText = '취소',
    this.confirmText = '확인',
    required this.onCancel,
    required this.onConfirm,
    this.isConfirmEnabled = true,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 취소 버튼
        Expanded(
          flex: 2,
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[700],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  cancelText,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // 확인 버튼
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: isConfirmEnabled ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              padding: padding,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  confirmText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
