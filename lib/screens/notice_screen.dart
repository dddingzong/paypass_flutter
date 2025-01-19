import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeScreen {
  static Future<void> show(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastDismissDate = prefs.getString('lastNoticeDismissDate');

    // 이전에 다이얼로그를 닫은 날짜 확인
    if (lastDismissDate != null) {
      final dismissDate = DateTime.parse(lastDismissDate);
      if (dismissDate.day == today.day &&
          dismissDate.month == today.month &&
          dismissDate.year == today.year) {
        return; // 오늘 이미 다이얼로그를 닫았다면 종료
      }
    }

    // 다이얼로그 표시
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('공지사항'),
          content: Text('테스트용 공지사항'),
          actions: [
            TextButton(
              onPressed: () async {
                // 오늘 하루 보지 않기 설정
                await prefs.setString(
                    'lastNoticeDismissDate', today.toIso8601String());
                Navigator.of(context).pop();
              },
              child: Text('오늘 하루 보지 않기'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 그냥 닫기
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
