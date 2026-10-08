import 'package:flutter/material.dart';
import 'package:mobile_cheche_kakkakk/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ไฟล์นี้ต้องมาจากการรัน flutterfire configure
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ตรวจสอบ Path ของไฟล์เหล่านี้ให้ถูกต้องตามโปรเจกต์ของคุณ
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
bool? seen = false;

void main() async {
  // 1. จำเป็นต้องมีบรรทัดนี้เมื่อใช้ async ใน main (มีอยู่แล้ว)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. --- ส่วนที่เพิ่มเข้ามา: เริ่มต้น Firebase ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ------------------------------------------

  // ส่วนตรวจสอบ SharedPreferences (โค้ดเดิมของคุณ)
  final prefs = await SharedPreferences.getInstance();
  seen = prefs.getBool('seen') ?? false;

  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "2093282251519893", // เลข App ID ของคุณเช่
      cookie: true,
      xfbml: true,
      version: "v18.0",
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Mobile App',
      // เช็คว่าเคยเข้าแอปหรือยัง ถ้ายังไป Intro ถ้าเคยแล้วไป Login
      home: seen == false ? const IntroScreen() : const LoginScreen(),
      // home: const MainScreen(),
    );
  }
}