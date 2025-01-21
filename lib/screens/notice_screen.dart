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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.all(10), // 팝업 창 간격
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '공지사항',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '테스트용 공지사항\n\n'
                  '여기에 공지사항 내용이 길게 들어갈 수 있습니다.\n'
                  '공지사항 내용을 길게 작성할 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        // 오늘 하루 보지 않기 설정
                        await prefs.setString(
                            'lastNoticeDismissDate', today.toIso8601String());
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '오늘 하루 보지 않기',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 그냥 닫기
                      },
                      child: Text(
                        '닫기',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
