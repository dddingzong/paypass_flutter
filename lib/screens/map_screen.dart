import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:paypass/screens/simple_log_screen.dart';
import 'package:paypass/screens/notice_screen.dart';
import 'package:paypass/screens/mypage_screen.dart';
import 'package:paypass/variables/globals.dart';
import 'package:paypass/utils/geofence_service.dart';
import 'package:paypass/utils/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();
  LatLng? _currentPosition;
  final Set<Circle> _circles = {}; // Geofence 영역 표시용

  @override
  void initState() {
    super.initState();
    setupGeofenceService();
    _initializeLocationService();
    _showNoticeDialogIfNeeded(); // 공지사항 다이얼로그 출력
  }

  // LocationService 초기화  -> 얘만 페이지별로 추가해주고 initState에 추가하여 호출시 동작 가능능
  Future<void> _initializeLocationService() async {
    _locationService.startLocationService();

    _locationService.startListening((position) {
      setState(() {
        _currentPosition = position;
      });

      // 지오펜싱 확인
      _locationService.checkGeofence(
          stations, position.latitude, position.longitude);
    });
  }

  // 공지사항 출력 관련
  Future<void> _showNoticeDialogIfNeeded() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NoticeScreen.show(context); // NoticeDialog 호출
    });
  }

  void _addGeofenceZonesToMap() {
    for (var station in stations) {
      final circle = Circle(
        circleId: CircleId(station['stationNumber'].toString()),
        center: LatLng(station['latitude'], station['longitude']),
        radius: 100, // 100m
        fillColor: const Color.fromARGB(255, 101, 182, 248)
            .withAlpha((0.4 * 255).toInt()), // 0.4 투명도
        strokeColor: Colors.blue,
        strokeWidth: 2,
      );

      setState(() {
        _circles.add(circle);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("지도 화면"),
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
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 16,
              ),
              markers: stations
                  .map((station) => Marker(
                        markerId: MarkerId(station['stationNumber'].toString()),
                        position:
                            LatLng(station['latitude'], station['longitude']),
                        infoWindow: InfoWindow(
                          title: '정류장 ${station['name']}',
                        ),
                      ))
                  .toSet(),
              circles: _circles,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _addGeofenceZonesToMap();
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
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
