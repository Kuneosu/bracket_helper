import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

class EmptyPlayerListWidget extends StatelessWidget {
  final VoidCallback? onAddPlayer;

  const EmptyPlayerListWidget({super.key, this.onAddPlayer});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.person_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '등록된 선수가 없습니다',
                style: TST.mediumTextRegular.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              if (onAddPlayer != null)
                ElevatedButton.icon(
                  onPressed: onAddPlayer,
                  icon: const Icon(Icons.person_add),
                  label: const Text('선수 추가하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CST.gray4,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
