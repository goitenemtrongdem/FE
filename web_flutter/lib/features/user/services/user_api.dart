import '../../../core/network/api_client.dart';

class UserApi {
  static Future<void> fillInfo(Map<String, dynamic> data) async {
    await ApiClient.post(
      'http://localhost:3000/users/fill-info',
      data,
    );
  }
}
