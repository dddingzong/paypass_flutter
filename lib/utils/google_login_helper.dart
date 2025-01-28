import 'package:google_sign_in/google_sign_in.dart';

import 'package:paypass/utils/logger.dart';

class GoogleLoginHelper {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email'], // 이메일 정보를 요청하기 위해 'email' 스코프 추가
  );

  Future<String?> login() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        return googleSignInAccount.email; // 이메일 반환
      }
    } catch (error) {
      logger.e('Google Login Error: $error');
    }
    return null; // 로그인 실패 시 null 반환
  }
}
