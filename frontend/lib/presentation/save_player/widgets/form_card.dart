import 'package:flutter/material.dart';

class FormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget content;

  /// 폼 카드 컴포넌트
  ///
  /// [icon] 카드 상단에 표시될 아이콘
  /// [title] 카드 제목
  /// [subtitle] 부제목 (선택사항)
  /// [content] 카드 내용
  const FormCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (아이콘과 제목)
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // 부제목 (존재하는 경우에만 표시)
            if (subtitle != null) ...[
              const SizedBox(height: 16),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],

            const SizedBox(height: 16),

            // 내용
            content,
          ],
        ),
      ),
    );
  }
}
