import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/routes/app_routes.dart';
import '../controllers/signin_controller.dart';
import '../../../core/widgets/back_button_widget.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  bool _navigated = false;

  @override
  Widget build(BuildContext context) {

    final controller = context.watch<SigninController>();

    /// ✅ Navigate khi login thành công
    if (controller.canNavigate && !_navigated) {

      _navigated = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: [

          const AppBackButton(),

          Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Welcome back!\nSignin to your account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.loading
                          ? null
                          : () async {
                              await controller.handleSignin();
                            },
                      child: controller.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                  ),

                  if (controller.message.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      controller.message,
                      style: TextStyle(
                        color: controller.success
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
