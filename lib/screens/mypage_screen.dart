import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paypass/variables/constants.dart';
import 'package:paypass/variables/globals.dart';

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late Map<String, dynamic> _userData;
  bool _isLoading = true; // 로딩 상태를 관리하는 플래그

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // 유저 데이터 가져오기
  }

  // 유저 데이터 가져오는 함수
  Future<void> _fetchUserData() async {
    final email = globalGoogleId;
    final url = Uri.parse('http://${Constants.ip}/mypage/info'); // 수정된 URL 경로

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // JSON 형식 명시
        },
        body: json.encode({
          'email': email, // 이메일을 Body로 전달
        }),
      );

      setState(() {
        _userData = json.decode(response.body);
        _isLoading = false; // 데이터 로드 완료
      });
    } catch (error) {
      print('유저 데이터 로드 중 오류 발생: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("마이페이지")),
        body: Center(child: CircularProgressIndicator()), // 로딩 중 표시
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("마이페이지"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("아이디: ${_userData['mainId']}", style: TextStyle(fontSize: 18)),
            Text("이름: ${_userData['name']}", style: TextStyle(fontSize: 18)),
            Text("생일: ${_userData['birth']}", style: TextStyle(fontSize: 18)),
            Text("전화번호: ${_userData['phoneNumber']}",
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
