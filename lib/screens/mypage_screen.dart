import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:paypass/screens/simple_log_screen.dart';
import 'package:paypass/screens/map_screen.dart';
import 'package:paypass/utils/logger.dart';
import 'package:paypass/variables/constants.dart';
import 'package:paypass/variables/globals.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late Map<String, dynamic> _userData;
  bool _isLoading = true; // 로딩 상태를 관리하는 플래그
  double _walletBalance = 0.0;
  // ignore: prefer_final_fields
  String _paymentDueDate = "2025-02-01";

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // 유저 데이터 가져오기
    _fetchWalletBalance();
  }

  // 유저 데이터 가져오는 함수
  Future<void> _fetchUserData() async {
    final email = globalGoogleId;
    final url = Uri.parse('http://${Constants.ip}/mypage/info'); // 수정된 URL 경로

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // JSON 형식 명시
        },
        body: json.encode({
          'email': email, // 이메일을 Body로 전달
        }),
      );

      setState(() {
        _userData = json.decode(utf8.decode(response.bodyBytes));
        _isLoading = false; // 데이터 로드 완료
      });
    } catch (error) {
      logger.e('유저 데이터 로드 중 오류 발생: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWalletBalance() async {
    final email = globalGoogleId;
    final url = Uri.parse('http://${Constants.ip}/mypage/account');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      // 응답 본문을 로그로 출력하여 확인
      logger.i('Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      setState(() {
        _walletBalance =
            responseData['account'].toDouble(); // account 값으로 잔액 갱신
      });
    } catch (error) {
      logger.e('지갑 잔액 업데이트 중 오류 발생: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("마이페이지")),
        body: Center(child: CircularProgressIndicator()), // 로딩 중 표시
      );
    }
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: 40,
              left: 20,
              child: Image.asset('assets/logo.png', width: 40),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Larger ID and Name with more spacing
              _buildUserInfo('ID:', _userData['mainId'], fontSize: 20),
              SizedBox(height: 12), // Increased spacing
              _buildUserInfo('이름:', _userData['name'], fontSize: 18),
              SizedBox(height: 12), // Increased spacing
              _buildUserInfo('생년월일:', _userData['birth'], fontSize: 15),
              SizedBox(height: 12),
              _buildUserInfo('전화번호:', _userData['phoneNumber'], fontSize: 15),

              SizedBox(height: 30),

              // PayPass Wallet 구역
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, // 배경색을 흰색으로 설정
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.blueAccent, width: 2), // 테두리 설정
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.grey.withAlpha((0.3 * 255).toInt()), // 그림자 효과
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "PAYPASS",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Text(
                      "WALLET",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "${_walletBalance.toStringAsFixed(0)}원",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showTransactionDialog("충전"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.blueAccent, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "충전",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showTransactionDialog("출금"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.blueAccent, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "출금",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Payment due date
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "결제 예정일(매주 월요일): $_paymentDueDate",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold),
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
          // Handle navigation for each button
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

  // Helper method to build user info with customizable font size
  Widget _buildUserInfo(String label, String value, {double fontSize = 18}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "$label $value",
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showTransactionDialog(String action) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$action 금액 입력"),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "금액 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                String choice =
                    action == "충전" ? "deposit" : "withdraw"; // 충전 또는 출금
                String change = amountController.text;

                if (change.isNotEmpty && double.tryParse(change) != null) {
                  await _updateWalletAccount(choice, change);
                } else {
                  logger.e("잘못된 금액 입력");
                }
              },
              child: Text(action),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateWalletAccount(String choice, String change) async {
    final email = globalGoogleId; // 로그인한 사용자의 이메일
    final url =
        Uri.parse('http://${Constants.ip}/mypage/update'); // Spring 서버 API URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body:
            json.encode({'mainId': email, 'change': change, 'choice': choice}),
      );

      // 성공적으로 업데이트된 경우 지갑 잔액 갱신
      setState(() {
        _walletBalance = json.decode(response.body)['balance'];
      });
    } catch (error) {
      logger.e('Error updating wallet balance: $error');
    }
  }
}
