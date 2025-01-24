import 'package:flutter/material.dart';
import 'dart:async'; // 타이머 사용을 위한 임포트
import 'package:pay_pass/screens/login_screen.dart'; // 로그인 화면
import 'package:pay_pass/screens/map_screen.dart'; // 실제 화면

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late bool _isBlue; // 색을 번갈아가며 변경할 플래그

  @override
  void initState() {
    super.initState();
    _isBlue = true; // 처음 색은 파랑으로 설정
    _loadData(); // 로딩 시작
    _startColorAnimation(); // 색 번갈아가며 변경
  }

  // 로딩 시간 시뮬레이션 후 화면 전환
  Future<void> _loadData() async {
    // 예시로 3초 동안 로딩을 시뮬레이션
    await Future.delayed(Duration(seconds: 3));

    // 로딩 끝나면 로그인 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면
    );
  }

  // 색 번갈아가며 변경하는 함수
  void _startColorAnimation() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _isBlue = !_isBlue; // 색 변경
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 로고 이미지 표시
            Image.asset(
              'assets/logo.png', // 로고 이미지 경로
              width: 100, // 로고의 크기
            ),
            SizedBox(height: 20), // 로고와 텍스트 사이 간격

            // PAYPASS 텍스트
            AnimatedSwitcher(
              duration: Duration(seconds: 1),
              child: Text(
                'PAYPASS',
                key: ValueKey<bool>(_isBlue),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _isBlue ? Colors.blue : Colors.indigo, // 색 번갈아가며
                ),
              ),
            ),

            SizedBox(height: 10), // PAYPASS 텍스트와 아래 텍스트 사이 간격

            // "대중교통의 새로운 경험" 텍스트
            Text(
              '대중교통의 새로운 경험',
              style: TextStyle(
                fontSize: 16, // 크기 설정
                fontWeight: FontWeight.normal,
                color: Colors.black, // 검정색
              ),
            ),

            SizedBox(height: 20), // 로딩 인디케이터와 텍스트 사이 간격
            CircularProgressIndicator(), // 로딩 인디케이터
          ],
        ),
      ),
    );
  }
}
