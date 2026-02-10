import 'package:flutter/material.dart';
import '../services/user_api.dart';

class FillInfoController extends ChangeNotifier {
  final fullname = TextEditingController();
  final address = TextEditingController();
  final birthday = TextEditingController();
  final citizen = TextEditingController();

  bool loading = false;
  String message = '';

  Future<void> submit() async {
    try {
      loading = true;
      notifyListeners();

      await UserApi.fillInfo({
        'fullname': fullname.text,
        'address': address.text,
        'birthday': birthday.text,
        'citizenNumber': citizen.text,
      });

      message = 'Submitted successfully';
    } catch (e) {
      message = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
