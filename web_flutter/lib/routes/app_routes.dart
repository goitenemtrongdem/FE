import 'package:flutter/material.dart';

import '../features/auth/pages/landing_page.dart';
import '../features/auth/pages/signin_page.dart';
import '../features/auth/pages/signup_page.dart';

class AppRoutes {
  static const landing = '/';
  static const signin = '/signin';
  static const signup = '/signup';

  static final Map<String, WidgetBuilder> routes = {
    landing: (context) => LandingPage(),
    signin: (context) => SignInPage(),
    signup: (context) => SignUpPage(),
  };
}
