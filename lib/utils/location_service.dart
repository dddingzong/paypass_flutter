import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';

import 'package:paypass/variables/globals.dart';
import 'package:paypass/variables/constants.dart';

class LocationService {
  final Location _location = Location();
  late WebSocketChannel _channel;
  final Logger _logger = Logger();

  static const double _geofenceRadius = Constants.geofenceRadius;
  final String websocketUrl = 'ws://${Constants.ip}/location';

  // 현재 위치 리스너
  StreamSubscription<LocationData>? _locationSubscription;

  LocationService();

  void startLocationService() async {
    await initializeWebSocket();
    await enableLocationServices();
    // 웬만해서는 다 함수로 묶는게 좋을듯
  }

  Future<void> initializeWebSocket() async {
    _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
    _logger.i("WebSocket 연결 완료: $websocketUrl");
  }

  // 위치 서비스 활성화 및 권한 요청
  Future<void> enableLocationServices() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 활성화 되어있지 않습니다.');
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('위치 권한이 거절 되었습니다.');
      }
    }
  }

  // 현재 위치를 추적하는 리스너 설정
  void startListening(Function(LatLng) onLocationChanged) async {
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
        onLocationChanged(currentPosition);

        // 위치 WebSocket 전송
        _sendLocation(locationData.latitude!, locationData.longitude!);
      }
    });
  }

  // WebSocket으로 위치 전송
  void _sendLocation(double latitude, double longitude) {
    final data = {
      'mainId': globalGoogleId,
      'latitude': latitude,
      'longitude': longitude
    };
    _channel.sink.add(jsonEncode(data));
    _logger.i("위치 데이터 전송: $data");
  }

  // 지오펜싱 범위 내에 있는지 확인
  void checkGeofence(
      List<Map<String, dynamic>> stations, double latitude, double longitude) {
    for (var station in stations) {
      double distance = _calculateDistance(
        station['latitude'],
        station['longitude'],
        latitude,
        longitude,
      );
      if (distance <= _geofenceRadius) {
        _logger.i("정류장 ${station['stationNumber']} 내에 있음");
      }
    }
    _logger.i("정류장 근처가 아님");
  }

  // 두 좌표 간 거리 계산 (Haversine 공식 사용)
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

  // 리소스 정리
  void dispose() {
    _locationSubscription?.cancel();
    _channel.sink.close();
  }
}
