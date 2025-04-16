import 'package:intl/intl.dart';

/// 날짜 형식 변환 유틸리티 클래스
class DateFormatter {
  /// DateTime을 'YYYY-MM-DD' 형식의 문자열로 변환
  static String formatToYYYYMMDD(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 문자열을 DateTime으로 변환 (YYYY-MM-DD 형식)
  static DateTime? parseFromYYYYMMDD(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
