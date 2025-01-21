import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pay_pass/screens/detailed_log_screen.dart';
import 'package:pay_pass/screens/mypage_screen.dart';
import 'package:pay_pass/screens/map_screen.dart';

class SimpleLogScreen extends StatelessWidget {
  final List<Map<String, dynamic>> logData = [
    {
      'date': '2025-01-18',
      'amount': '5000 원',
      'status': '완료',
      'details': '선릉역 -> 한티역',
    },
    {
      'date': '2025-01-19',
      'amount': '4500 원',
      'status': '예정',
      'details': '야탑역 -> 수서역',
    },
    // Add more log entries here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('활동 로그'),
      ),
      body: ListView.builder(
        itemCount: logData.length,
        itemBuilder: (context, index) {
          final log = logData[index];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('날짜: ${log['date']}'),
              subtitle: Text('금액: ${log['amount']}\n결제 상태: ${log['status']}'),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  // Navigate to a detailed view screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedlogScreen(log: log),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '상세 로그'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
        onTap: (index) {
          // 각 버튼에 맞는 화면으로 이동
          switch (index) {
            case 0:
              // 지도 화면으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
              break;
            case 1:
              // 상세 로그 화면으로 이동 (상세 로그 화면은 별도로 구현되어 있어야 합니다)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SimpleLogScreen()),
              );
              break;
            case 2:
              // 마이페이지로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyPageScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
