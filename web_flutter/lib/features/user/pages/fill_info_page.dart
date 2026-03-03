import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/fill_info_controller.dart';

class FillInfoPage extends StatefulWidget {
  const FillInfoPage({super.key});

  @override
  State<FillInfoPage> createState() => _FillInfoPageState();
}

class _FillInfoPageState extends State<FillInfoPage> {

  final fullNameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final birthdayCtrl = TextEditingController();
  final citizenCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  bool loading = false;

  Future submit() async {
    try {
      setState(() => loading = true);

      final controller =
          Provider.of<FillInfoController>(context, listen: false);

      await controller.fillInfo(
        fullname: fullNameCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        birthday: birthdayCtrl.text.trim(),
        citizenNumber: citizenCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
      );

      Navigator.pushReplacementNamed(context, "/dashboard");

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F1F7),
    body: Center(
      child: SingleChildScrollView(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
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
                "Complete your profile",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Please fill in your personal information",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: fullNameCtrl,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: birthdayCtrl,
                decoration: const InputDecoration(
                  labelText: "Birthday (YYYY-MM-DD)",
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: citizenCtrl,
                decoration: const InputDecoration(
                  labelText: "Citizen Number",
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
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
                      : const Text(
                          "Submit",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}