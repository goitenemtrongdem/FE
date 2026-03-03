// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../controllers/signup_controller.dart';
// import '../../../core/widgets/back_button_widget.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   bool _navigated = false; // 🚫 chống navigate nhiều lần

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final controller = context.watch<SignupController>();

//     // ✅ CHỈ CHUYỂN TRANG 1 LẦN DUY NHẤT
//     if (controller.canNavigate && !_navigated) {
//       _navigated = true;

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacementNamed(context, '/fill-info');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.watch<SignupController>();

//     return Scaffold(
//       body: Stack(
//         children: [
//           const AppBackButton(),

//           Center(
//             child: Container(
//               width: 420,
//               padding: const EdgeInsets.all(32),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Welcome back\nSign up to your account',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 32),

//                   TextField(
//                     controller: controller.emailController,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   TextField(
//                     controller: controller.passwordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Password',
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: controller.loading
//                           ? null
//                           : () async {
//                               await controller.handleSignup();
//                             },
//                       child: controller.loading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             )
//                           : const Text('Next'),
//                     ),
//                   ),

//                   if (controller.message.isNotEmpty) ...[
//                     const SizedBox(height: 16),
//                     Text(
//                       controller.message,
//                       style: TextStyle(
//                         color: controller.success
//                             ? Colors.green
//                             : Colors.red,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/signup_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  bool sent = false;

  // STEP 1: Signup
Future signup() async {
  try {

    final controller =
        Provider.of<SignupController>(context, listen: false);

    setState(() => loading = true);

    await controller.signup(
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
    );

    setState(() => sent = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Check email to verify")),
    );

  } catch (e) {
    showError(e.toString());
  }

  setState(() => loading = false);
}

  // STEP 2: Next
Future next() async {
  try {

    final controller =
        Provider.of<SignupController>(context, listen: false);

    setState(() => loading = true);

    await controller.verifyAndSave();

    Navigator.pushReplacementNamed(
      context,
      "/fill-info",
    );

  } catch (e) {
    showError(e.toString());
  }

  setState(() => loading = false);
}

  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F1F7),
    body: Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Welcome back!\nSign up to your account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : (!sent ? signup : next),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6D9F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        sent ? "Next" : "Sign Up",
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}