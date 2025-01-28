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

    if (!context.mounted) return; // context가 유효하지 않으면 바로 종료

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
          child: Column(
            children: [
              // 공지사항 제목
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Text(
                  '공지사항',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 공지사항 내용
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '첫 공지사항 입니다\n\n'
                      '금요일에는 소주를 마시고 싶습니다.\n\n\n\n\n\n'
                      '이상입니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // 버튼 영역
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        // 오늘 하루 보지 않기 설정
                        await prefs.setString(
                            'lastNoticeDismissDate', today.toIso8601String());
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
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
              ),
            ],
          ),
        );
      },
    );
  }
}
