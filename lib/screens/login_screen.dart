import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:pay_pass/utils/get_stations_service.dart';
import 'package:pay_pass/utils/google_login_helper.dart';
import 'package:pay_pass/screens/map_screen.dart';
import 'package:pay_pass/variables/constants.dart';
import 'package:pay_pass/variables/globals.dart';
import 'new_user_screen.dart';

class LoginScreen extends StatelessWidget {
  final GoogleLoginHelper googleLoginHelper = GoogleLoginHelper();

  void _handleGoogleLogin(BuildContext context) async {
    String? googleId = await googleLoginHelper.login();

    print("구글 로그인 성공: $googleId");
    globalGoogleId = googleId; // 전역 변수에 저장

    // 지도 데이터 가져오기
    GetStationsService getStationsService = GetStationsService();
    getStationsService.fetchStations();

    final response = await http.post(
      Uri.parse('http://${Constants.ip}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'googleId': googleId}), // type 필요없음 (url로 구분가능)
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 'EXISTING_USER') {
        print("EXISTING_USER 데이터 확인");
        // 기존 유저 일시
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      }

      if (responseBody['status'] == 'NEW_USER') {
        print("NEW_USER 데이터 확인");
        // 신규 유저 일시
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewUserScreen()),
        );
      }
    } else {
      print("서버 오류: ${response.statusCode}");
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

            // 로그인 버튼
            ElevatedButton(
              onPressed: () => null,
              child: Text("로그인"),
            ),
            SizedBox(height: 20),

            // 소셜 로그인 버튼들
            ElevatedButton.icon(
              onPressed: () => _handleGoogleLogin(context),
              icon: Icon(Icons.g_mobiledata, color: Colors.white),
              label: Text("구글 로그인"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () {
                print("네이버 로그인 시도");
                // 네이버 로그인 로직 추가 가능
              },
              icon: Icon(Icons.person, color: Colors.white),
              label: Text("네이버 로그인"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () {
                print("카카오 로그인 시도");
                // 카카오 로그인 로직 추가 가능
              },
              icon: Icon(Icons.chat_bubble, color: Colors.white),
              label: Text("카카오 로그인"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            ),
          ],
        ),
      ),
    );
  }
}
