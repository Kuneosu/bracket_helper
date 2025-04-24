import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:bracket_helper/main.dart';

class EmailFeedbackLauncher {
  static const String _developerEmail = 'brackethelper@gmail.com';
  static const String _subject = '[대진 도우미] 문의 및 피드백';
  static const String _body = '''
안녕하세요, 대진 도우미 개발자입니다.

아래에 문의하실 내용이나 피드백을 자유롭게 작성해 주세요.
-------------------------------------------------

앱 버전: v1.0.0
기기 정보: 

-------------------------------------------------
''';

  // 이 앱 패키지 이름으로 시작하는 uri 처리를 위한 리스너 설정
  static bool _isListenerRegistered = false;

  static Future<void> launch(BuildContext context) async {
    // 리스너가 등록되지 않았다면 등록
    if (!_isListenerRegistered) {
      _registerMailtoStreamListener(context);
      _isListenerRegistered = true;
    }

    try {
      // 이메일 URI 생성
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: _developerEmail,
        query: _encodeQueryParameters({'subject': _subject, 'body': _body}),
      );

      // 선택기 열기
      await launchUrl(emailUri, mode: LaunchMode.externalApplication).then((
        success,
      ) {
        // 앱이 취소했거나 실패한 경우
        if (!success && context.mounted) {
          // 이 경우는 1) 사용자가 자신의 앱을 선택했거나 2) 다른 이유로 실패한 경우
          // mailtoLinkStream이 처리하지 않으면 스낵바 표시
          _showErrorDialog(context);

          // _showSelectEmailAppSnackBar(context);
        }
      });
    } catch (e) {
      // 이메일 앱 실행 실패 시 다이얼로그 표시
      if (context.mounted) {
        _showErrorDialog(context);
      }
    }
  }

  // mailto 스트림 리스너 등록
  static void _registerMailtoStreamListener(BuildContext context) {
    mailtoLinkStream.stream.listen((uri) {
      // mailto 링크가 감지되면 스낵바 표시
      if (context.mounted) {
        _showErrorDialog(context);

        // _showSelectEmailAppSnackBar(context);
      }
    });
  }

  // 이메일 앱 선택 안내 스낵바
  // static void _showSelectEmailAppSnackBar(BuildContext context) {
  //   if (context.mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             Icon(Icons.info_outline, color: Colors.white, size: 20),
  //             SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 '이메일 앱을 선택해 주세요. 대진 도우미 앱은 이메일을 처리할 수 없습니다.',
  //                 style: TST.smallTextRegular.copyWith(color: Colors.white),
  //               ),
  //             ),
  //           ],
  //         ),
  //         backgroundColor: CST.primary100,
  //         duration: const Duration(seconds: 3),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //       ),
  //     );
  //   }
  // }

  // 에러 다이얼로그 표시 함수
  static void _showErrorDialog(BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              '이메일 앱 실행 불가',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '죄송합니다. 현재 기본 메일앱 사용이 불가능하여 앱에서 바로 메일을 전송할 수 없습니다.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CST.primary100.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '아래 이메일로 연락주시면 빠르게 답변드리도록 하겠습니다:',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          _developerEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CST.primary100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: CST.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: CST.gray4, width: 1),
                  ),
                ),
                child: Text(
                  '확인',
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
          );
        },
      );
    }
  }

  // URL 쿼리 파라미터 인코딩 헬퍼 함수
  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }
}
