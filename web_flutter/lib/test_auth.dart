import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Custom token lấy từ backend
  final customToken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlhdCI6MTc3MjE4MDk5MiwiZXhwIjoxNzcyMTg0NTkyLCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay1mYnN2Y0Bpb3QtY2hvbmctdHJvbS14ZS1tYXkuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJzdWIiOiJmaXJlYmFzZS1hZG1pbnNkay1mYnN2Y0Bpb3QtY2hvbmctdHJvbS14ZS1tYXkuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJ1aWQiOiJqVXFSajdMdFdYVU9ieGgwclJJQ3JXdzZ5SUMyIn0.JldjBsY0IoDuEoqP2wYOjjwRvsOPpaiWoW3TSc6Z9O5p3EB9xjuVX8UfkBGgeQnFHbaIwsuwKUzCco7WWDR_PTAvqCziCUpw7iOzbp7De9jIHc6pJzejG6l2azQluXGTVEpoc67OWM7UTXInkAQFFGpRFYjvPWE7_EeEzL3Hf310dQryPJ1dg05uic5-TEh9RFUAPWnPYw0rrAjff9xaK0_5v4pW6lQSw02Qpt5DI3ld5fYn1xRUMiTyMjDiN2-AstZLWhlk4KnhzR40twYAJqeMHYNSBKCl_0YN4q7QmpT_bngDWWJR2UaGOle3-HCy3sKLiecsxH8ZT5oBe8Vagw";

  try {
    // 1. Login
    final cred = await FirebaseAuth.instance
        .signInWithCustomToken(customToken);

    print("✅ Login OK: ${cred.user!.uid}");

    // 2. Get ID Token
    final idToken = await cred.user!.getIdToken(true);

    print("🔥 ID TOKEN:");
    print(idToken);

  } catch (e) {
    print("❌ ERROR:");
    print(e);
  }
}