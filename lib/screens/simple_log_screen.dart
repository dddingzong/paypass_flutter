import 'package:flutter/material.dart';

import 'package:paypass/screens/detailed_log_screen.dart';
import 'package:paypass/screens/mypage_screen.dart';
import 'package:paypass/screens/map_screen.dart';
import 'package:paypass/utils/location_service.dart';
import 'package:paypass/variables/globals.dart';

class SimpleLogScreen extends StatefulWidget {
  const SimpleLogScreen({super.key});

  @override
  State<SimpleLogScreen> createState() => _SimpleLogScreenState();
}

class _SimpleLogScreenState extends State<SimpleLogScreen> {
  final LocationService _locationService = LocationService();
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
  void initState() {
    super.initState();
    _initializeLocationService();
  }

  // LocationService 초기화  -> 얘만 페이지별로 추가해주고 initState에 추가하여 호출시 동작 가능능
  Future<void> _initializeLocationService() async {
    _locationService.startLocationService();

    _locationService.startListening((position) {
      // 지오펜싱 확인
      _locationService.checkGeofence(
          stations, position.latitude, position.longitude);
    });
  }

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

  @override
  void dispose() {
    _locationService.dispose(); // 리소스 정리
    super.dispose();
  }
}
