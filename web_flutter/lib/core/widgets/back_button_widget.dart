import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 32,
      left: 24,
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(30),
        child: const Row(
          children: [
            Icon(Icons.arrow_back_ios, size: 18),
            SizedBox(width: 4),
            Text(
              'Back',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
