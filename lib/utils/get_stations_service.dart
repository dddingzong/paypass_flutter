import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:paypass/variables/globals.dart';
import 'package:paypass/variables/constants.dart';

class GetStationsService {
  // Spring 서버에서 정류장 데이터를 가져오는 함수
  Future<void> fetchStations() async {
    final url = Uri.parse('http://${Constants.ip}/getStations');
    try {
      final response = await http.get(url);
      final List<dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));

      stations = jsonData
          .map((station) => {
                'name': station['name'],
                'stationNumber': station['stationNumber'],
                'latitude': station['latitude'],
                'longitude': station['longitude'],
              })
          .toList();

      print("정류장 데이터 로드 성공");
    } catch (error) {
      print("정류장 데이터 로드 중 오류 발생: $error");
    }
  }
}
