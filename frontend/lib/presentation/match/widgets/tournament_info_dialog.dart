import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class TournamentInfoDialog extends StatelessWidget {
  final TournamentModel tournament;
  final int playersCount;
  final int matchesCount;
  final VoidCallback onClose;

  const TournamentInfoDialog({
    super.key,
    required this.tournament,
    required this.playersCount,
    required this.matchesCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 아이콘과 제목
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CST.primary40,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: CST.primary100,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.tournamentInfo,
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 토너먼트 정보 내용
            _buildInfoItem(Icons.title, AppStrings.titleLabel, tournament.title),
            const SizedBox(height: 12),
            _buildInfoItem(Icons.people, AppStrings.participantsCountLabel, 
                AppStrings.participantsCountValue.replaceAll('%d', playersCount.toString())),
            const SizedBox(height: 12),
            _buildInfoItem(Icons.sports_tennis, AppStrings.matchesCountLabel, 
                AppStrings.matchesCountValue.replaceAll('%d', matchesCount.toString())),
            
            const SizedBox(height: 24),
            
            // 확인 버튼
            Center(
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  foregroundColor: CST.white,
                  backgroundColor: CST.primary100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  AppStrings.close,
                  style: TST.smallTextBold.copyWith(color: CST.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: CST.primary80,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TST.smallTextBold.copyWith(color: CST.gray2),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TST.normalTextRegular.copyWith(color: CST.gray1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 다이얼로그를 표시하는 정적 메서드
  static Future<void> show({
    required BuildContext context,
    required TournamentModel tournament,
    required int playersCount,
    required int matchesCount,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => TournamentInfoDialog(
        tournament: tournament,
        playersCount: playersCount,
        matchesCount: matchesCount,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
} 