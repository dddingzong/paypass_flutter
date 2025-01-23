import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:paypass/utils/get_stations_service.dart';
import 'package:paypass/utils/google_login_helper.dart';
import 'package:paypass/utils/notification_service.dart';
import 'package:paypass/screens/map_screen.dart';
import 'package:paypass/variables/constants.dart';
import 'package:paypass/variables/globals.dart';
import 'new_user_screen.dart';

class LoginScreen extends StatelessWidget {
  final GoogleLoginHelper googleLoginHelper = GoogleLoginHelper();

  void _handleGoogleLogin(BuildContext context) async {
    String? googleId = await googleLoginHelper.login();

    print("구글 로그인 성공: $googleId");
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
      appBar: AppBar(title: Text("로그인 화면")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleGoogleLogin(context),
          child: Text("구글 로그인"),
        ),
      ),
    );
  }
}
