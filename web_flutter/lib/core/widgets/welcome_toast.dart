import 'package:flutter/material.dart';
 
void showWelcomeToast(BuildContext context) {
  final overlay = Overlay.of(context);

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _WelcomeToast(
      onFinish: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class _WelcomeToast extends StatefulWidget {
  final VoidCallback onFinish;
  const _WelcomeToast({required this.onFinish});

  @override
  State<_WelcomeToast> createState() => _WelcomeToastState();
}

class _WelcomeToastState extends State<_WelcomeToast>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    animation = Tween<Offset>(
      begin: const Offset(1, 0), // từ phải
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    controller.forward();

    // Sau 3s thì chạy animation thoát
    Future.delayed(const Duration(seconds: 3), () async {
      await controller.reverse();
      widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
      right: 20,
      child: SlideTransition(
        position: animation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // ✅ nền trắng
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                )
              ],
            ),
            child: const Text(
              "👋 Welcome back!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}