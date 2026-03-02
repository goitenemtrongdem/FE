import 'package:flutter/material.dart';

import '../features/auth/pages/landing_page.dart';
import '../features/auth/pages/signin_page.dart';
import '../features/auth/pages/signup_page.dart';
import 'package:web_flutter/features/dashboard/pages/dashboard_page.dart';
import '../features/user/pages/fill_info_page.dart';
class AppRoutes {
  static const signin = '/signin';
  static const signup = '/signup';
  static const dashboard = "/dashboard";
  static const fillInfo = "/fill-info";
  static final Map<String, WidgetBuilder> routes = {
    signin: (context) => SigninPage(),
    signup: (context) => SignupPage(),
    fillInfo: (context) => const FillInfoPage(),
    dashboard: (context) => const DashboardPage(),
  };
}
 