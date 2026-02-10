import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/fill_info_controller.dart';
import '../../../core/widgets/back_button_widget.dart';

class FillInfoPage extends StatelessWidget {
  const FillInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FillInfoController>();

    return Scaffold(
      body: Stack(
        children: [
          const AppBackButton(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Fill all to submit', style: TextStyle(fontSize: 24)),
                TextField(controller: c.fullname, decoration: const InputDecoration(labelText: 'Your fullname')),
                TextField(controller: c.address, decoration: const InputDecoration(labelText: 'Your address')),
                TextField(controller: c.birthday, decoration: const InputDecoration(labelText: 'Your birthday')),
                TextField(controller: c.citizen, decoration: const InputDecoration(labelText: 'Your citizen number')),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: c.loading ? null : c.submit,
                  child: const Text('Submit'),
                ),
                if (c.message.isNotEmpty) Text(c.message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
