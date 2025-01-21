import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pay_pass/screens/mypage_screen.dart';

import 'package:pay_pass/utils/get_stations_service.dart';
import 'package:pay_pass/utils/google_login_helper.dart';
import 'package:pay_pass/screens/map_screen.dart';
import 'package:pay_pass/variables/constants.dart';
import 'package:pay_pass/variables/globals.dart';
import 'package:pay_pass/screens/new_user_screen.dart';

class DetailLogScreen extends StatelessWidget {
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
                      builder: (context) => DetailedInfoScreen(log: log),
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
                MaterialPageRoute(builder: (context) => DetailLogScreen()),
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

class DetailedInfoScreen extends StatelessWidget {
  final Map<String, dynamic> log;

  DetailedInfoScreen({required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세 내역'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('날짜: ${log['date']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('금액: ${log['amount']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('결제 상태: ${log['status']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Text('부가:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(log['details'], style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '활동 로그'),
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
                MaterialPageRoute(builder: (context) => DetailLogScreen()),
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
