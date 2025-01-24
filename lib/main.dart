import 'package:flutter/material.dart';
import 'package:pay_pass/screens/loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pay_pass',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingScreen(), // 앱 시작 시 로딩 화면 표시
    );
  }
}
