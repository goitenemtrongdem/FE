
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
  Map<String, dynamic>? userProfile;
bool isLoadingProfile = false;
bool isEditingProfile = false;
bool showUserMenu = false;
final fullNameController = TextEditingController();
final dobController = TextEditingController();
final addressController = TextEditingController();
final phoneController = TextEditingController();
final citizenController = TextEditingController();
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

void showEditDeviceDialog(Map<String, dynamic> device) {
  final brandCtrl = TextEditingController(text: device["brand"]);
  final colorCtrl = TextEditingController(text: device["color"]);
  final plateCtrl = TextEditingController(text: device["licensePlate"]);
  final modelCtrl = TextEditingController(text: device["model"]);
  final verifyCtrl = TextEditingController();

  String? errorText;
  bool isLoading = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Device",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: brandCtrl,
                    decoration: const InputDecoration(labelText: "Brand"),
                  ),
                  TextField(
                    controller: modelCtrl,
                    decoration: const InputDecoration(labelText: "Model"),
                  ),
                  TextField(
                    controller: colorCtrl,
                    decoration: const InputDecoration(labelText: "Color"),
                  ),
                  TextField(
                    controller: plateCtrl,
                    decoration: const InputDecoration(labelText: "License Plate"),
                  ),

                  TextField(
                    controller: verifyCtrl,
                    decoration: InputDecoration(
                      labelText: "Verification Code",
                      errorText: errorText,
                    ),
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setStateDialog(() {
                                  isLoading = true;
                                  errorText = null;
                                });

                                final body = {
                                  "id": device["id"],
                                  "brand": brandCtrl.text,
                                  "model": modelCtrl.text,
                                  "color": colorCtrl.text,
                                  "licensePlate": plateCtrl.text,
                                  "verificationCode": verifyCtrl.text,
                                };

                                try {
                                  await updateDevice(body); // 👈 API call

                                  Navigator.pop(context); // success
                                } catch (e) {
                                  setStateDialog(() {
                                    errorText = e.toString().replaceAll("Exception: ", "");
                                  });
                                }

                                setStateDialog(() {
                                  isLoading = false;
                                });
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Save"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
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

Future<void> updateUserProfile() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    final response = await http.post(
      Uri.parse("http://localhost:3000/api/user/update-profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({
        "userId": currentUserId,
        "fullName": fullNameController.text,
        "dateOfBirth": dobController.text,
        "address": addressController.text,
        "phoneNumber": phoneController.text,
        "citizenNumber": citizenController.text,
      }),
    );

    if (response.statusCode == 200) {
      await fetchUserProfile(); // load lại data mới
      setState(() {
        isEditingProfile = false;
      });
    } else {
      print("Update profile failed: ${response.body}");
    }
  } catch (e) {
    print("updateUserProfile error: $e");
  }
}
Future<void> updateDevice(Map<String, dynamic> device) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    final response = await http.put(
      Uri.parse("http://localhost:3000/api/device/update-device"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({
        "id": device["id"],
        "brand": device["brand"],
        "color": device["color"],
        "licensePlate": device["licensePlate"],
        "model": device["model"],
        "verificationCode": device["verificationCode"],
      }),
    );

    if (response.statusCode == 200) {
      await fetchDevicesFromApi();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Device updated successfully")),
      );
    } else {
      print("Update failed: ${response.body}");
    }
  } catch (e) {
    print("updateDevice error: $e");
  }
}
Future<void> deleteDevice(String deviceId) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    final response = await http.delete(
      Uri.parse("http://localhost:3000/api/device/delete-device"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({
        "deviceID": deviceId,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Device deleted");

      // reload list
      await fetchDevicesFromApi();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Device deleted successfully")),
      );
    } else {
      print("❌ Delete failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete device failed")),
      );
    }
  } catch (e) {
    print("❌ deleteDevice error: $e");
  }
}
  @override
void initState() {
  super.initState();
  // loadDevices();
  loadUserId();
  fetchUserProfile(); 
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

Future<void> markAllAsRead() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    final response = await http.post(
      Uri.parse("http://localhost:3000/api/notification/mark-all-as-read"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({
        "userId": currentUserId,
      }),
    );

    if (response.statusCode == 200) {
      print("All notifications marked as read");
    } else {
      print("Failed: ${response.body}");
    }
  } catch (e) {
    print("Error markAllAsRead: $e");
  }
}

Future<void> fetchUserProfile() async {
  try {
    setState(() => isLoadingProfile = true);

    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    if (currentUserId == null) {
      print("currentUserId is null");
      return;
    }

    final response = await http.post(
      Uri.parse("http://localhost:3000/api/user/get-profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode({
        "userId": currentUserId, // 👈 BẮT BUỘC
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      setState(() {
        userProfile = decoded["data"];
      });
    } else {
      print("Get profile failed: ${response.body}");
    }
  } catch (e) {
    print("fetchUserProfile error: $e");
  } finally {
    setState(() => isLoadingProfile = false);
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

Stream<int> unreadNotificationCountStream(String userId) {
  return FirebaseFirestore.instance
      .collection("user-notifications")
      .doc(userId)
      .collection("items")
      .where("isRead", isEqualTo: false) // 👈 CHỈ LẤY CHƯA ĐỌC
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
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

        // ===== HEADER ROW (ID + 3 DOT MENU) =====
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.confirmation_number, size: 18),
                const SizedBox(width: 6),
                Text(device["id"] ?? ""),
              ],
            ),

            // 🔥 3 DOT MENU
PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert),
  onSelected: (value) async {
    if (value == "edit") {
      showEditDeviceDialog(device); // 👈 GỌI FORM EDIT
    } 
    else if (value == "delete") {

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm delete"),
          content: Text("Delete device ${device["id"]}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await deleteDevice(device["id"]);
      }
    }
  },
  itemBuilder: (context) => const [
    PopupMenuItem(
      value: "edit",
      child: Row(
        children: [
          Icon(Icons.edit, size: 18),
          SizedBox(width: 8),
          Text("Edit"),
        ],
      ),
    ),
    PopupMenuItem(
      value: "delete",
      child: Row(
        children: [
          Icon(Icons.delete, size: 18, color: Colors.red),
          SizedBox(width: 8),
          Text("Delete"),
        ],
      ),
    ),
  ],
),
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
leading: index == 2
    ? StreamBuilder<int>(
        stream: currentUserId == null
            ? const Stream.empty()
            : unreadNotificationCountStream(currentUserId!), // 👈 stream mới
        builder: (context, snapshot) {
          int count = snapshot.data ?? 0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                menuIcons[index],
                size: 26,
                color: selectedIndex == index
                    ? Colors.blue
                    : Colors.black54,
              ),

              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      "$count",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      )
    : Icon(
        menuIcons[index],
        color: selectedIndex == index
            ? Colors.blue
            : Colors.black54,
      ),

  title: Text(
    menuItems[index],   // 👈 QUAN TRỌNG
    style: TextStyle(
      color: selectedIndex == index ? Colors.blue : Colors.black,
      fontWeight:
          selectedIndex == index ? FontWeight.bold : FontWeight.normal,
    ),
  ),

  selected: selectedIndex == index,

  onTap: () {
    setState(() {
      selectedIndex = index;
    });
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
: selectedIndex == 0
    ? buildUserPage()   // 👈 USERS PAGE
    : selectedIndex == 1
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Vehicle",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                buildAddVehicleCard(),
                const SizedBox(height: 20),
                if (showForm) ...[
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
                      ],
                    ),
                  )
                ],
                const SizedBox(height: 30),
                 ...devices.map((device) => buildDeviceBox(device)).toList(),
              ],
            ),
          )
        : buildNotificationsPage(currentUserId!),
            ),
    ),
  ],
),
    );
  }

IconData getNotificationIcon(String title) {
  switch (title) {
    case "ADD_DEVICE":
      return Icons.add_circle; // ➕ thêm xe
    case "UPDATE_DEVICE":
      return Icons.edit; // ✏️ sửa xe
    case "DELETE_DEVICE":
      return Icons.delete; // 🗑 xóa xe
    case "UPDATE_PROFILE":
      return Icons.person; // 👤 cập nhật hồ sơ

    case "ON_ANTI_THEFT":
      return Icons.lock; // 🔒
    case "OFF_ANTI_THEFT":
      return Icons.lock_open; // 🔓

    case "SOS":
    case "LOST1":
    case "LOST2":
      return Icons.warning; // ⚠️

    case "signin":
      return Icons.login; // 🔑
    case "signup":
      return Icons.person_add; // 👥

    default:
      return Icons.notifications;
  }
}

Color getNotificationColor(String title) {
  switch (title) {
    case "ADD_DEVICE":
      return Colors.green; // thành công
    case "UPDATE_DEVICE":
      return Colors.blue; // chỉnh sửa
    case "DELETE_DEVICE":
      return Colors.red; // nguy hiểm
    case "UPDATE_PROFILE":
      return Colors.purple; // hồ sơ

    case "ON_ANTI_THEFT":
      return Colors.green;
    case "OFF_ANTI_THEFT":
      return Colors.orange;

    case "SOS":
    case "LOST1":
    case "LOST2":
      return Colors.redAccent;

    case "signin":
    case "signup":
      return Colors.blue;

    default:
      return Colors.grey;
  }
}
Widget buildNotificationsPage(String userId) {

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

      return Column(
        children: [
          // 🔥 ICON CHECK GÓC PHẢI
          // 🔔 NOTIFICATION ICON + BADGE
Align(
  alignment: Alignment.topRight,
  child: Padding(
    padding: const EdgeInsets.only(right: 16, top: 8),
    child: InkWell(
      onTap: () async {
       await markAllAsRead();
        // TODO: sau này mark all as read
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            )
          ],
        ),
        child: const Icon(
          Icons.done,   // 👈 icon dấu ✓ giống hình bạn gửi
          color: Colors.black,
          size: 22,
        ),
      ),
    ),
  ),
),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final data = notifications[index];

                final String title = data.title;
                final String content = data.content;
                final String deviceId = data.deviceId ?? "";
                final DateTime time = data.createdAt;

                final formattedTime =
                    DateFormat('hh:mm a dd-MM-yyyy').format(time);

                final icon = getNotificationIcon(title);
                final color = getNotificationColor(title);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(icon, color: color, size: 30),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(content),
                          const SizedBox(height: 4),
                                if (title != "signin" && title != "signup")
        // Text(
        //   "Device: $deviceId",
        //   style: const TextStyle(
        //     fontSize: 12,
        //     color: Color.fromARGB(255, 72, 64, 64),
        //   ),
        // ),
                          if (deviceId.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Device ID: $deviceId",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
Widget buildUserPage() {
  if (isLoadingProfile) {
    return const Center(child: CircularProgressIndicator());
  }

  if (userProfile == null) {
    return const Center(child: Text("No user data"));
  }

  return Stack(
    children: [
      // ===== MAIN CONTENT =====
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER + MENU ICON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Owner",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () {
                      setState(() {
                        showUserMenu = true;
                      });
                    },
                  )
                ],
              ),

              const SizedBox(height: 24),

              // ===== VIEW MODE =====
              if (!isEditingProfile) ...[
                buildProfileRow(Icons.person, "Name", userProfile!["fullName"]),
                const Divider(),

                buildProfileRow(Icons.cake, "Dob", userProfile!["dateOfBirth"]),
                const Divider(),

                buildProfileRow(Icons.location_on, "Address", userProfile!["address"]),
                const Divider(),

                buildProfileRow(Icons.phone, "Phone number", userProfile!["phoneNumber"]),
                const Divider(),

                buildProfileRow(Icons.badge, "Citizen ID", userProfile!["citizenNumber"]),
                const SizedBox(height: 30),

                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditingProfile = true;

                        // fill data vào controller
                        fullNameController.text = userProfile!["fullName"] ?? "";
                        dobController.text = userProfile!["dateOfBirth"] ?? "";
                        addressController.text = userProfile!["address"] ?? "";
                        phoneController.text = userProfile!["phoneNumber"] ?? "";
                        citizenController.text = userProfile!["citizenNumber"] ?? "";
                      });
                    },
                    child: const Text("Edit information"),
                  ),
                ),
              ]

              // ===== EDIT MODE =====
              else ...[
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(labelText: "Dob"),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone number"),
                ),
                TextField(
                  controller: citizenController,
                  decoration: const InputDecoration(labelText: "Citizen ID"),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: updateUserProfile,
                      child: const Text("Save"),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isEditingProfile = false;
                        });
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),

      // ===== SLIDE MENU (RIGHT PANEL) =====
      AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        top: 0,
        bottom: 0,
        right: showUserMenu ? 0 : -260,
        child: Container(
          width: 260,
  decoration: BoxDecoration(

    color: const Color.fromARGB(255, 255, 255, 255),   // ✅ color nằm trong BoxDecoration
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(-2, 0),
      ),
    ],
  ),
          child: Column(
            children: [
              const SizedBox(height: 40),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Setting"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text("Help"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text("Link Device"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text("Store"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {},
              ),

              const Spacer(),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    showUserMenu = false;
                  });
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ],
  );
}
Widget buildProfileRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "$label: $value",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
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