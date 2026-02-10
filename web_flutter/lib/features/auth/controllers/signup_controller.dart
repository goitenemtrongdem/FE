import 'package:flutter/material.dart';
import '../services/auth_api.dart';

class SignupController extends ChangeNotifier {
  final AuthApi _authApi = AuthApi();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool success = false;

  /// Để hiển thị message dưới nút
  String message = '';
  bool canNavigate = false;
  /// Đánh dấu đã signup hay chưa
  bool signedUp = false;

  /// Lưu idToken để dùng cho các bước sau
  String? _idToken;

  /// ===============================
  /// NEXT / VERIFIED BUTTON HANDLER
  /// ===============================
  Future<void> handleSignup() async {
    if (loading) return;

    try {
      loading = true;
      message = '';
      notifyListeners();

      // ===============================
      // LẦN 1: SIGN UP + SEND VERIFY MAIL
      // ===============================
      if (!signedUp) {
        final res = await _authApi.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        _idToken = res['idToken'];

        await _authApi.sendVerifyEmail(idToken: _idToken!);

        signedUp = true;
        success = true;
        message = 'Đã gửi email xác nhận. Vui lòng kiểm tra Gmail.';
        return;
      }

      // ===============================
      // LẦN 2: CHECK EMAIL VERIFIED
      // ===============================
      final verified =
          await _authApi.checkEmailVerified(idToken: _idToken!);

      if (!verified) {
        success = false;
        message = 'Email chưa được xác nhận. Vui lòng kiểm tra lại.';
        return;
      }

      // ===============================
      // CALL BACKEND AFTER VERIFY
      // ===============================
      await AuthApi.afterVerify(idToken: _idToken!);

      success = true;
      message = 'Email xác nhận thành công. Đang chuyển trang...';
       
      // 👉 Điều hướng sang trang fill info
      // (UI hoặc Router sẽ xử lý phần này)
    } catch (e) {
      
      message = _friendlyError(e.toString());
      canNavigate = true;
    } catch (e) {
      message = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ===============================
  /// XỬ LÝ ERROR CHO DỄ NHÌN
  /// ===============================
  String _friendlyError(String raw) {
    if (raw.contains('EMAIL_EXISTS')) {
      return 'Email đã tồn tại. Vui lòng đăng nhập.';
    }
    if (raw.contains('INVALID_PASSWORD')) {
      return 'Mật khẩu không hợp lệ.';
    }
    return raw;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
