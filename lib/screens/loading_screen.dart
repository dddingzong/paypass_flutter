import 'dart:async'; // 타이머 사용을 위한 임포트

import 'package:flutter/material.dart';

import 'package:paypass/screens/login_screen.dart'; // 로그인 화면

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key}); // 성능 최적화화

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
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

    // mounted 여부 확인 후 화면 전환 (State가 여전히 유효한지 검증)
    // 현재 화면이 여전히 표시되고 있는지, 또는 해당 위젯이 아직 트리에서 제거되지 않았는지를 확인
    // mounted == true: 위젯이 여전히 화면 위에 있으며 State도 유효하다.
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면
      );
    }
  }

// 색 번갈아가며 변경하는 함수
  void _startColorAnimation() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _isBlue = !_isBlue; // 색 변경
        });
      } else {
        timer.cancel(); // State가 해제되면 타이머 중지
      }
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
