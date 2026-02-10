import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? 'API error');
    }
    return data;
  }
}
