import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:paypass/utils/get_stations_service.dart';
import 'package:paypass/utils/google_login_helper.dart';
import 'package:paypass/utils/logger.dart';
import 'package:paypass/utils/notification_service.dart';
import 'package:paypass/screens/map_screen.dart';
import 'package:paypass/variables/constants.dart';
import 'package:paypass/variables/globals.dart';
import 'new_user_screen.dart';

class LoginScreen extends StatelessWidget {
  final GoogleLoginHelper googleLoginHelper = GoogleLoginHelper();

  LoginScreen({super.key});

  void _handleGoogleLogin(BuildContext context) async {
    String? googleId = await googleLoginHelper.login();

    logger.i("구글 로그인 성공: $googleId");
    globalGoogleId = googleId; // 전역 변수에 저장

    // 지도 데이터 가져오기
    GetStationsService getStationsService = GetStationsService();
    await getStationsService.fetchStations();
    await createNotificationChannel();

    final response = await http.post(
      Uri.parse('http://${Constants.ip}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'googleId': googleId}), // type 필요없음 (url로 구분가능)
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 'EXISTING_USER') {
        logger.i("EXISTING_USER 데이터 확인");
        // 기존 유저 일시
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        }
      }

      if (responseBody['status'] == 'NEW_USER') {
        logger.i("NEW_USER 데이터 확인");
        // 신규 유저 일시
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NewUserScreen()),
          );
        }
      }
    } else {
      logger.e("서버 오류: ${response.statusCode}");
    } // response.statusCode != 200
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 로고 이미지
            Image.asset(
              'assets/logo.png', // 로고 경로
              width: 200, // 크기 조정
              height: 200,
            ),
            SizedBox(height: 20),

            // 아이디 입력 필드
            TextField(
              decoration: InputDecoration(
                labelText: "아이디",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // 비밀번호 입력 필드
            TextField(
              obscureText: true, // 비밀번호 가림 효과
              decoration: InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // 로그인 정보 저장 체크박스와 회원가입 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: true, // 초기 상태 (true: 체크, false: 체크 해제)
                      onChanged: (bool? newValue) {
                        logger.i("로그인 정보 저장 체크 상태: $newValue");
                      },
                    ),
                    Text("로그인 정보 저장"),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    logger.i("회원가입 클릭");
                    // 회원가입 페이지로 이동하는 로직 추가 가능
                  },
                  child: Text(
                    "회원가입",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                logger.i("로그인 시도");
                // 로그인 처리 로직 추가
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "로그인",
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),

            // 소셜 로그인 버튼들
            GestureDetector(
              onTap: () => _handleGoogleLogin(context),
              child: Image.asset(
                'assets/google_button.png', // 구글 버튼 이미지
                width: double.infinity, // 버튼 너비는 화면에 맞게 확장
                height: 50, // 이미지 크기 고정
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                logger.i("카카오 로그인 시도");
              },
              child: Image.asset(
                'assets/kakao_button.png', // 카카오 버튼 이미지
                width: double.infinity, // 버튼 너비는 화면에 맞게 확장
                height: 50, // 이미지 크기 고정
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
