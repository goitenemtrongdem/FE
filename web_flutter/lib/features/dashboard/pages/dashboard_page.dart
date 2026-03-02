import 'dart:convert';
import 'package:flutter/material.dart';
import '../controllers/device_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'map_page.dart';
import '../../auth/services/auth_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/device_api.dart';
import '../services/notification_api.dart';
import '../models/notification_model.dart';
import '../../../core/widgets/welcome_toast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// import '../controllers/signin_controller.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
// IO.Socket? socket;
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthApi authApi = AuthApi();
  // IO.Socket? socket;
  int selectedIndex = 1;
  bool showForm = false;
  bool isLoading = false;
  bool isFetching = false;
  // bool showWelcomeToast = false;
  String formatTime(Timestamp timestamp) {
  final date = timestamp.toDate();
  return DateFormat("hh:mm a yyyy-MM-dd").format(date);
}
Color getColor(int type) {
  if (type == 1) return Colors.red;
  if (type == 2) return Colors.green;
  if (type == 3) return Colors.black;
  return Colors.grey;
}
bool showMap = false;
double? selectedLat;
double? selectedLng;
StreamSubscription<DatabaseEvent>? _locationSubscription;
String? _currentDocKey;
void openMap(double lat, double lng) {
  setState(() {
    selectedLat = lat;
    selectedLng = lng;
    showMap = true;
  });
}

void closeMap() async {
  await _locationSubscription?.cancel();
  _locationSubscription = null;
  _currentDocKey = null;

  setState(() {
    showMap = false;
  });
}
void showWelcomeBox() {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 30,
      right: 30,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
              )
            ],
          ),
          child: const Text(
            "👋 Welcome back!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3)).then((_) {
    overlayEntry.remove();
  });
}
  final _formKey = GlobalKey<FormState>();

  final deviceIdController = TextEditingController();
  final verificationCodeController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final colorController = TextEditingController();
  final licensePlateController = TextEditingController();

  // List<Map<String, dynamic>> devices = [];
  String? currentUserId;

  List<Map<String, dynamic>> devices = [];
bool isLoadingDevices = false;

Future<void> fetchDevicesFromApi() async {
  try {
    setState(() {
      isLoadingDevices = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    final response = await http.post(
      Uri.parse("http://localhost:3000/api/device/get-devices-by-user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({
        "userId": currentUserId,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded["data"];

      setState(() {
        devices = data.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } else {
      print("Fetch devices failed: ${response.body}");
    }
  } catch (e) {
    print("Fetch error: $e");
  } finally {
    setState(() {
      isLoadingDevices = false;
    });
  }
}
  @override
void initState() {
  super.initState();
  // loadDevices();
  loadUserId();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showWelcomeToast(context); // 👈 gọi hàm riêng
  });
}
Future<void> loadUserId() async {
  final String? userId = await authApi.getUserId();

  setState(() {
    currentUserId = userId;
  });

  if (userId != null) {
    await fetchDevicesFromApi(); // 👈 GỌI API TẠI ĐÂY
  }
}
 @override
void dispose() {
  // socket?.disconnect();
  // socket?.dispose();
  _locationSubscription?.cancel();
  super.dispose();
}

  final List<String> menuItems = [
    "Users",
    "Motorbikes",
    "Notifications",
  ];
final List<IconData> menuIcons = [
  Icons.person,
  Icons.directions_bike,
  Icons.notifications,
];
  // ================= FETCH DEVICES =================


  // ================= SUBMIT DEVICE =================
  Future<void> submitDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await DeviceController.addDevice(
      context: context,
      deviceId: deviceIdController.text.trim(),
      verificationCode: verificationCodeController.text.trim(),
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      color: colorController.text.trim(),
      licensePlate: licensePlateController.text.trim(),
    );

      if (success) {

    await fetchDevicesFromApi();   // 🔥 ĐẶT NGAY ĐÂY

    setState(() {
      showForm = false;
    });

    deviceIdController.clear();
    verificationCodeController.clear();
    brandController.clear();
    modelController.clear();
    colorController.clear();
    licensePlateController.clear();
  }

    setState(() => isLoading = false);
  }
Future<void> toggleAntiThief(String deviceId, bool value) async {
  try {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await http.post(
      Uri.parse("http://localhost:3000/devices/anti-theft"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({
        "deviceId": deviceId,
        "antiThief": value,
      }),
    );

    if (response.statusCode == 200) {
      print("AntiThief updated successfully");
    } else {
      print("Failed: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> handleInspect(String deviceId) async {
  try {
    final authApi = AuthApi();
    final idToken = await authApi.getToken();

    if (idToken == null) {
      print("Token not found");
      return;
    }

    final response = await http.post(
      Uri.parse("http://localhost:3000/devices/find-doc-id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({"id": deviceId}),
    );

    if (response.statusCode != 200) {
      print("Find docId failed: ${response.body}");
      return;
    }

    final decoded = jsonDecode(response.body);

    final rawId = decoded["docId"];
    if (rawId == null) {
      print("docId not found in response");
      return;
    }

    final docKey = rawId.toString().trim();

    print("Reading key: $docKey");

    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: Firebase.app().options.databaseURL,
    );

// Lưu docKey hiện tại
_currentDocKey = docKey;

// Huỷ listener cũ nếu có
await _locationSubscription?.cancel();

// Listen realtime
_locationSubscription = database
    .ref("locations/$docKey")
    .onValue
    .listen((event) {

  if (!event.snapshot.exists) {
    print("Location not found in realtime");
    return;
  }

  final data =
      Map<String, dynamic>.from(event.snapshot.value as Map);

  final lat = (data["lat"] as num).toDouble();
  final lng = (data["lng"] as num).toDouble();

  print("Realtime update: $lat , $lng");

  openMap(lat, lng);
});

  } catch (e) {
    print("Inspect error: $e");
  }
}
List<NotificationModel> notifications = [];
bool isLoadingNotifications = false;


Stream<List<NotificationModel>> notificationStream(String userId) {
  return FirebaseFirestore.instance
      .collection("user-notifications")
      .doc(userId)
      .collection("items")
      .orderBy("createdAt", descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
      });
}


Stream<List<Map<String, dynamic>>> deviceStream(String userId) {
  return FirebaseFirestore.instance
      .collection("devices")
      .where("userId", isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data["docId"] = doc.id; // giữ id document
          return data;
        }).toList();
      });
}


 
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // ================= DEVICE BOX (NEW UI) =================
 Widget buildDeviceBox(Map<String, dynamic> device) {

  bool antiThief = device["antiThief"] == true;

  return Container(
    width: 350,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 10,
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            const Icon(Icons.confirmation_number, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(device["id"] ?? "")),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(Icons.directions_bike, size: 18),
            const SizedBox(width: 6),
            Text("${device["brand"] ?? ""} ${device["model"] ?? ""}"),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            const Icon(Icons.color_lens, size: 18),
            const SizedBox(width: 6),
            Text("Color: ${device["color"] ?? ""}"),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            const Icon(Icons.credit_card, size: 18),
            const SizedBox(width: 6),
            Text("Plate: ${device["licensePlate"] ?? ""}"),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Anti Theft"),
            Switch(
              value: antiThief,
              onChanged: (value) async {
                setState(() {
                  device["antiThief"] = value;
                });

                await toggleAntiThief(device["id"], value);
              },
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              handleInspect(device["id"]);
            },
            child: const Text("Inspect"),
          ),
        ),
      ],
    ),
  );
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Row(
  children: [
    // 🔹 Sidebar giữ nguyên
    Container(
      width: 220,
      color: Colors.grey.shade100,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
return ListTile(
  leading: Icon(
    menuIcons[index],
    color: selectedIndex == index
        ? Colors.blue
        : Colors.black54,
  ),
  title: Text(
    menuItems[index],
    style: TextStyle(
      color: selectedIndex == index
          ? Colors.blue
          : Colors.black87,
      fontWeight: selectedIndex == index
          ? FontWeight.bold
          : FontWeight.normal,
    ),
  ),
                  selected: selectedIndex == index,
                  selectedTileColor: Colors.blue.shade100,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      showMap = false; // 🔥 reset map khi đổi menu
                    });
  //                   if (index == 2) {
  //                     //  await loadNotifications(); // 🔥 gọi API tại đây
  // }
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),

    // 🔹 Content bên phải
    Expanded(
      child: showMap && selectedLat != null && selectedLng != null
          ? Stack(
              children: [
MapPage(
  lat: selectedLat!,
  lng: selectedLng!,
  onBack: closeMap,
),

                // 🔥 Nút Back nổi góc trái
                Positioned(
                  top: 20,
                  left: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: closeMap,
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: selectedIndex == 1
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Vehicle",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          
                          buildAddVehicleCard(),
                          const SizedBox(height: 20),
                          if (showForm)
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  buildTextField("Device ID", deviceIdController),
                                  buildTextField("Verification Code", verificationCodeController),
                                  buildTextField("Brand", brandController),
                                  buildTextField("Model", modelController),
                                  buildTextField("Color", colorController),
                                  buildTextField("License Plate", licensePlateController),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          isLoading ? null : submitDevice,
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : const Text("Submit"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 30),
currentUserId == null
  ? const Center(child: CircularProgressIndicator())
   :
isLoadingDevices
    ? const Center(child: CircularProgressIndicator())
    : devices.isEmpty
        ? const Text("No vehicles found")
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: devices
                .map((device) => buildDeviceBox(device))
                .toList(),
          )
                        ],
                      ),
                    )
                 : selectedIndex == 2
    ? currentUserId == null
        ? const Center(child: CircularProgressIndicator())
        : buildNotificationsPage(currentUserId!)
    : const Center(child: Text("Coming soon...")),
            ),
    ),
  ],
),
    );
  }
Widget buildNotificationsPage(String userId) {
  print("🟡 buildNotificationsPage userId = $userId"); // 👈 thêm dòng này
  return StreamBuilder<List<NotificationModel>>(
    stream: notificationStream(userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text("No notifications"));
      }

      final notifications = snapshot.data!;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final data = notifications[index];

          final String title = data.title;
          final String content = data.content;
          final int type = data.type;
          final DateTime time = data.createdAt;

          final formattedTime =
              DateFormat('hh:mm a dd-MM-yyyy').format(time);

          Color titleColor;
          IconData icon;

          if (type == 1) {
            titleColor = Colors.red;
            icon = Icons.warning;
          } else if (type == 2) {
            titleColor = Colors.green;
            icon = Icons.lock_open;
          } else {
            titleColor = Colors.black;
            icon = Icons.notifications;
          }

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(icon, color: titleColor),
              title: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(content),
                  const SizedBox(height: 6),
                  Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
  Widget buildAddVehicleCard() {
    return Center(
      child: InkWell(
        onTap: () {
          setState(() {
            showForm = !showForm;
          });
        },
        child: Container(
          width: 400,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
            color: Colors.blue.shade50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline,
                  size: 32, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                "Add vehicle here",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Don’t have device info? Please add device",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}