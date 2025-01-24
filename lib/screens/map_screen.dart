import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pay_pass/screens/simple_log_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:pay_pass/screens/notice_screen.dart';
import 'package:pay_pass/screens/mypage_screen.dart';
import 'package:pay_pass/variables/globals.dart';
import 'package:pay_pass/variables/constants.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => MapScrrenState();
}

class MapScrrenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();
  LatLng? _currentPosition;
  late WebSocketChannel _channel;
  final Set<Circle> _circles = {}; // Geofence 영역 표시용

  // 지오펜싱을 위한 중심 좌표와 반경
  static const double _geofenceRadius = Constants.geofenceRadius;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _showNoticeDialogIfNeeded(); // 공지사항 다이얼로그 출력
    _getCurrentLocation();
  }

  // WebSocket 초기화
  void _initializeWebSocket() {
    _channel = WebSocketChannel.connect(
      // 지정된 url로 연결을 생성
      Uri.parse('ws://${Constants.ip}/location'),
    );
    print("WebSocket connected");
  }

  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // 위치 서비스 활성화 확인
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        throw Exception('위치 서비스가 활성화 되어있지 않습니다.');
      }
    }

    // 위치 권한 확인
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception('위치 권한이 거절 되었습니다.');
      }
    }

    // 현재 위치 가져오기
    final locationData = await _location.getLocation();
    setState(() {
      // setState: UI를 업데이트
      _currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
    });

    // 위치 변경을 실시간으로 모니터링
    _location.onLocationChanged.listen((newLocation) {
      setState(() {
        _currentPosition =
            LatLng(newLocation.latitude!, newLocation.longitude!);
      });

      // WebSocket을 통해 현재 위치 전송
      _sendLocation(newLocation.latitude!, newLocation.longitude!);
    });
  }

  // WebSocket으로 위치 전송하는 함수
  void _sendLocation(double latitude, double longitude) {
    final data = {
      'mainId': globalGoogleId,
      'latitude': latitude,
      'longitude': longitude
    };
    print("Sending data: $data");
    _channel.sink.add(jsonEncode(data));
  }

  // 지오펜싱 범위 내에 있는지 확인하는 함수
  // 뭔 어머같은 함수임 이건
  // 다 뜯어고쳐야함
  void _checkGeofence(double latitude, double longitude) {
    bool isNearStation = false; // 정류장 근처 여부를 확인하는 플래그

    for (var station in stations) {
      double distance = _calculateDistance(
        station['center'].latitude,
        station['center'].longitude,
        latitude,
        longitude,
      );

      if (distance <= _geofenceRadius) {
        print("정류장 ${station['stationNumber']}에 서있음");

        // 출력용 데이터 (stationData는 전송하지 않음)
        print("stationData (출력용): ${{
          'name': station['name'],
          'stationNumber': station['stationNumber'],
          'latitude': latitude,
          'longitude': longitude,
        }}");
        isNearStation = true;
        return; // 정류장을 찾았으므로 메서드 종료
      }
    }

    if (!isNearStation) {
      print("정류장 근처가 아님");
      // 출력용 데이터 (stationData는 전송하지 않음)
      print("stationData (출력용): ${{
        'stationNumber': 0,
        'latitude': latitude,
        'longitude': longitude,
      }}");
    }
  }

  // 두 좌표 간의 거리 계산 (Haversine 공식 사용)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double radiusOfEarth = 6371;
    double latDistance = _degToRad(lat2 - lat1);
    double lonDistance = _degToRad(lon2 - lon1);
    double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(lonDistance / 2) *
            sin(lonDistance / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusOfEarth * c;
  }

  double _degToRad(double degree) {
    return degree * (pi / 180);
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
                        position: station['center'],
                        infoWindow: InfoWindow(
                          title: '정류장 ${station['stationNumber']}',
                        ),
                      ))
                  .toSet(),
              circles: _circles,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _addGeofenceZonesToMap();
              },
              // myLocationEnabled: true,
              // myLocationButtonEnabled: true,
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
    _channel.sink.close();
    super.dispose();
  }
}
