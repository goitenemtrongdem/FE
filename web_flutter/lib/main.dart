// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'firebase_options.dart';
// import 'package:web_flutter/features/dashboard/pages/dashboard_page.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'routes/app_routes.dart';
// import 'features/auth/controllers/signup_controller.dart';
// import 'features/auth/controllers/signin_controller.dart';
// import 'features/user/controllers/fill_info_controller.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//    final database = FirebaseDatabase.instanceFor(
//   app: Firebase.app(),
//   databaseURL: "https://iot-chong-trom-xe-may-default-rtdb.asia-southeast1.firebasedatabase.app",
// );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => SignupController()),
//         ChangeNotifierProvider(create: (_) => SigninController()),
//         ChangeNotifierProvider(create: (_) => FillInfoController()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         initialRoute: AppRoutes.landing,
//         routes: AppRoutes.routes,
//         //  AppRoutes.dashboard: (context) => const DashboardPage(),

//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'features/dashboard/pages/dashboard_page.dart';
import 'features/auth/pages/landing_page.dart';
import 'features/auth/controllers/signup_controller.dart';
import 'features/auth/controllers/signin_controller.dart';
import 'features/user/controllers/fill_info_controller.dart';
import 'core/services/fcm_debug_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ✅ Xin quyền notification
    await FirebaseMessaging.instance.requestPermission();
      // ✅ Lấy FCM token
  final fcm = await FirebaseMessaging.instance.getToken();

  print("🔥 INIT FCM TOKEN = $fcm");
  // 🔥 Giữ session khi F5 trên Web
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  await FcmDebugService.debugFCM();
  // Realtime Database
  FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://iot-chong-trom-xe-may-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupController()),
        ChangeNotifierProvider(create: (_) => SigninController()),
      Provider(
  create: (_) => FillInfoController(),
),
      ],
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ⏳ Đợi Firebase restore session
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            routes: AppRoutes.routes,

            // 🔥 QUAN TRỌNG: Không dùng initialRoute nữa
            home: snapshot.hasData
                ? const DashboardPage()
                : const LandingPage(),
          );
        },
      ),
    );
  }
}