import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paypass/utils/logger.dart';

import 'package:paypass/variables/constants.dart';
import 'package:paypass/variables/globals.dart';
import 'map_screen.dart';

class NewUserScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  NewUserScreen({super.key});

  bool _isValidDate(String date) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return regex.hasMatch(date);
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^\d{10,11}$');
    return regex.hasMatch(phone);
  }

  Future<void> _submitNewUser(BuildContext context) async {
    final name = nameController.text.trim();
    final birth = birthController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || birth.isEmpty || phone.isEmpty) {
      logger.i('모든 필드를 입력하세요.');
      return;
    }

    if (!_isValidDate(birth)) {
      logger.i('생년월일 형식이 잘못되었습니다. (YYYY-MM-DD)');
      return;
    }

    if (!_isValidPhone(phone)) {
      logger.i('전화번호 형식이 잘못되었습니다.');
      return;
    }

    final response = await http.post(
      Uri.parse('http://${Constants.ip}/new-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mainId': globalGoogleId,
        'name': name,
        'birth': birth,
        'phoneNumber': phone,
      }),
    );

    if (response.statusCode == 200) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      }
    } else {
      logger.e('회원가입 실패: ${response.statusCode}');
    } // response.statusCode != 200
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: 40, // 화면 상단에서 40px 아래
              left: 20, // 화면 왼쪽에서 20px 오른쪽
              child: Image.asset(
                'assets/logo.png', // 로고 이미지 경로
                width: 40, // 로고 너비
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "이름"),
            ),
            TextField(
              controller: birthController,
              decoration: InputDecoration(labelText: "생년월일 (YYYY-MM-DD)"),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "전화번호"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitNewUser(context),
              child: Text("회원가입 완료"),
            ),
          ],
        ),
      ),
    );
  }
}
