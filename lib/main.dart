import 'package:flutter/material.dart';
import 'package:paypass/screens/login_screen.dart';

// main: 애플리케이션의 진입점
// runApp: Flutter 위젯 트리를 시작하는 함수, 여기서는 MyApp을 루트 위젯으로 설정
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayPass',
      home: LoginScreen(),
    );
  }
}
