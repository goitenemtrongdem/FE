import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<Map<String, dynamic>> signupRequest({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup-request'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    // Backend luôn trả JSON
    final data = jsonDecode(response.body);

    // FE xử lý theo success (không đoán)
    return {
      'statusCode': response.statusCode,
      ...data,
    };
  }
}
