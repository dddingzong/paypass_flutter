import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pay_pass/screens/mypage_screen.dart';
import 'package:pay_pass/screens/simple_log_screen.dart';
import 'package:pay_pass/screens/map_screen.dart';

class DetailedlogScreen extends StatefulWidget {
  final Map<String, dynamic> log;

  DetailedlogScreen({required this.log});

  @override
  _DetailedInfoScreenState createState() => _DetailedInfoScreenState();
}

class _DetailedInfoScreenState extends State<DetailedlogScreen> {
  late GoogleMapController _controller;

  // 더미 좌표 (실제 데이터로 교체 필요)
  final LatLng _startLocation = LatLng(37.514722, 127.059444); // 선릉역 예시
  final LatLng _endLocation = LatLng(37.482222, 127.038611); // 한티역 예시

  // 팝업을 띄우는 함수
  void _showDetailsPopup(BuildContext context, String details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이동 내역', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(details),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text('닫기', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

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
              // 구글 맵을 여기에 추가
              Container(
                height: 300, // 맵 높이 설정
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _startLocation, // 맵의 초기 카메라 위치 (출발지점)
                    zoom: 12,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('start'),
                      position: _startLocation,
                      infoWindow: InfoWindow(
                          title:
                              '시작: ${widget.log['details'].split(' -> ')[0]}'),
                    ),
                    Marker(
                      markerId: MarkerId('end'),
                      position: _endLocation,
                      infoWindow: InfoWindow(
                          title:
                              '끝: ${widget.log['details'].split(' -> ')[1]}'),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                ),
              ),

              // 정보 카드 추가
              SizedBox(height: 40),
              Text('날짜: ${widget.log['date']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('금액: ${widget.log['amount']}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('결제 상태: ${widget.log['status']}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),

              // 상세 이동 내역 보기 텍스트를 클릭하면 팝업을 띄우도록 변경
              GestureDetector(
                onTap: () {
                  _showDetailsPopup(context, widget.log['details']);
                },
                child: Text(
                  '상세 이동 내역 보기',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),

              // '문의 : 대중교통 미 이용' 버튼 추가
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 버튼 클릭 시 수행할 동작 (예: 전화 걸기, 이메일 전송 등)
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('문의',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        content: Text('대중교통 미 이용에 대한 문의가 접수되었습니다.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('확인',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0), //
                  child: Text(
                    ' 문의 : 대중교통 미 이용',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange, width: 2),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
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
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SimpleLogScreen()),
              );
              break;
            case 2:
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
