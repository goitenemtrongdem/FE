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
      appBar: AppBar(title: const Text("Fill Info")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: fullNameCtrl,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),

              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: "Address"),
              ),

              TextField(
                controller: birthdayCtrl,
                decoration: const InputDecoration(
                  labelText: "Birthday (YYYY-MM-DD)",
                ),
              ),

              TextField(
                controller: citizenCtrl,
                decoration: const InputDecoration(labelText: "Citizen Number"),
              ),

              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: loading ? null : submit,
                child: const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}