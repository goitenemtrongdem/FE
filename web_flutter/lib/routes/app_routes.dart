import 'package:flutter/material.dart';
import '../features/auth/pages/signup_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/signup': (_) => const SignupPage(),
  };
}
