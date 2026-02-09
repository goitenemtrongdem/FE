import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/signup_controller.dart';
import '../../../core/widgets/back_button_widget.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SignupController>();

    return Scaffold(
      body: Stack(
        children: [
          const AppBackButton(), // ✅ đúng: Positioned trong Stack

          Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back\nSign up to your account',
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
                              await controller.handleSignup();
                            },
                      child: controller.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Next'),
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
