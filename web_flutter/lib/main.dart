import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/app_routes.dart';
import 'features/auth/controllers/signup_controller.dart';
import 'features/user/controllers/fill_info_controller.dart';
import 'features/auth/pages/landing_page.dart';
import 'features/auth/pages/signin_page.dart';
import 'features/auth/pages/signup_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SignupController(),
        ),

        // ⭐ THÊM CÁI NÀY
        ChangeNotifierProvider(
          create: (_) => FillInfoController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.landing, // ⭐ landing đầu tiên
      routes: AppRoutes.routes,
    );
  }
}

