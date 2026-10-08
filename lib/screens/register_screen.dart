import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🟢 เพิ่ม import สำหรับ Firestore
import '../constant/my_constant.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(); // 🟢 เอาช่อง Email กลับมา
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ฟังก์ชันแสดง Dialog เมื่อสมัครสำเร็จ
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // บังคับให้กดปุ่ม OK เท่านั้น
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // Icon ติ๊กถูกสีเขียว
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9), // เขียวอ่อน
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                // หัวข้อ
                Text(
                  "Account Created!",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 10),
                // รายละเอียด
                Text(
                  "Your account has been successfully created. Please log in to continue.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 25),
                // ปุ่ม OK
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // ปิด Dialog
                      // กลับไปหน้า Login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Ok",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _register() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_usernameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both Username and Email"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 1. สร้างบัญชีผู้ใช้ใน Firebase Auth ด้วย Email และ Password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. 🟢 บันทึก Username คู่กับ Email ลงใน Cloud Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // เมื่อสมัครและบันทึกข้อมูลสำเร็จ เรียกใช้ Dialog
      if (mounted) {
        _showSuccessDialog();
      }
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: lightColor),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                  Text("Car.Hub", style: subHeaderTextStyle),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Text("Create Account", style: headerTextStyle),
                        const SizedBox(height: 8),
                        Text(
                          "Sign up to get started with your journey",
                          style: bodyTextStyle,
                        ),
                        const SizedBox(height: 30),

                        _CustomInputField(
                          label: "Username",
                          hint: "example123",
                          icon: Icons.person_outline,
                          controller: _usernameController,
                        ),
                        const SizedBox(height: 15),

                        // 🟢 ช่อง Email Address นำกลับมาใส่ไว้ใต้ Username
                        _CustomInputField(
                          label: "Email Address",
                          hint: "example@email.com",
                          icon: Icons.email_outlined,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 15),

                        _CustomInputField(
                          label: "Password",
                          hint: "••••••••",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 15),

                        _CustomInputField(
                          label: "Confirm Password",
                          hint: "••••••••",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _confirmPasswordController,
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            child: Text("SIGN UP", style: buttonTextStyle),
                          ),
                        ),

                        const SizedBox(height: 25),
                        Center(
                          child: Text(
                            "Or sign up with",
                            style: bodyTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialLoginButton(
                              imagePath: "lib/images/google_logo.png",
                              fallbackIcon: Icons.g_mobiledata,
                              color: Colors.red,
                            ),
                            SizedBox(width: 20),
                            _SocialLoginButton(
                              imagePath: "lib/images/facebook_logo.png",
                              fallbackIcon: Icons.facebook,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: bodyTextStyle),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                "Log In",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        
                        Center(
                          child: Container(
                            width: 120,
                            height: 5,
                            decoration: BoxDecoration(
                              color: subTextColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CUSTOM WIDGETS =================

class _CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const _CustomInputField({
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelTextStyle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(color: darkColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: bodyTextStyle.copyWith(color: subTextColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: Icon(icon, color: primaryColor),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: subTextColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: lightColor,
          ),
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String imagePath;
  final IconData fallbackIcon;
  final Color color;

  const _SocialLoginButton({
    required this.imagePath,
    required this.fallbackIcon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            imagePath,
            errorBuilder: (context, error, stackTrace) {
              return Icon(fallbackIcon, size: 24, color: color);
            },
          ),
        ),
      ),
    );
  }
}