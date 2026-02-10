import '../../../core/network/api_client.dart';

class AuthApi {
  static const String _apiKey =
      'AIzaSyDicr5ZKJVqiIZhXOArU6NYesMmtnvZmKo';

  /// 1️⃣ SIGN UP → LẤY idToken
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
      {
        "email": email,
        "password": password,
        "returnSecureToken": true,
      },
    );

    return response;
  }

  /// 2️⃣ SEND VERIFY EMAIL
  Future<void> sendVerifyEmail({
    required String idToken,
  }) async {
    await ApiClient.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey',
      {
        "requestType": "VERIFY_EMAIL",
        "idToken": idToken,
      },
    );
  } 

Future<bool> checkEmailVerified({
  required String idToken,
}) async  {
  final res = await ApiClient.post(
    'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey',
    {
      "idToken": idToken,
    },
  );

  return res['users'][0]['emailVerified'] == true;
}

  /// 3️⃣ AFTER VERIFY → BACKEND NODEJS
  static Future<void> afterVerify({
    required String idToken,
  }) async {
    await ApiClient.post(
      'http://localhost:3000/auth/after-verify',
      {
        "idToken": idToken,
      },
    );
  }
}
