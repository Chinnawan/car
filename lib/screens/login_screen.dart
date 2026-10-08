import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:google_sign_in/google_sign_in.dart'; 
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; 

import 'main_screen.dart';
import 'register_screen.dart';
import '../constant/my_constant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController(); 
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    String input = _loginController.text.trim();
    String password = _passwordController.text.trim();
    String loginEmail = input; 

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Username/Email and Password")),
      );
      return;
    }

    try {
      if (!input.contains('@')) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: input)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Username not found.")),
            );
          }
          return; 
        }

        loginEmail = querySnapshot.docs.first.data()['email'];
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen(showLoginSuccessPopup: true)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
         errorMessage = "No user found for that email/username.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
         errorMessage = "Wrong password provided.";
      } else {
         errorMessage = e.message ?? "Login failed";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // บนเว็บใช้ popup ของ Firebase แทน google_sign_in (signIn() บนเว็บ deprecated และไม่ได้ idToken)
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen(showLoginSuccessPopup: true)),
          );
        }
        return;
      }

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen(showLoginSuccessPopup: true)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In Error: $e")),
        );
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final AuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
        
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen(showLoginSuccessPopup: true)),
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
         print("Facebook login cancelled");
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Facebook Error: ${result.message}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Facebook Sign-In Error: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
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
                mainAxisAlignment: MainAxisAlignment.end, // 🟢 เปลี่ยนเป็น end เพื่อให้ข้อความชิดขวาเสมอ
                children: [
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
                        const SizedBox(height: 100),
                        
                        Center(
                          child: Column(
                            children: [
                              Text("Log In", style: headerTextStyle),
                              const SizedBox(height: 8),
                              Text(
                                "Log in to your account of Car.Hub", // 🟢 ชื่อแอป
                                style: bodyTextStyle,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),

                        _CustomInputField(
                          label: "Username or Email",
                          hint: "Enter username or email",
                          icon: Icons.person_outline,
                          controller: _loginController,
                        ),

                        const SizedBox(height: 15),

                        _CustomInputField(
                          label: "Password",
                          hint: "••••••••",
                          icon: Icons.lock_outline, 
                          isPassword: true,
                          showForgotPassword: true,
                          controller: _passwordController,
                          // 🟢 เพิ่มโค้ดส่วนนี้เมื่อกด Forgot Password
                          onForgotPasswordPressed: () {
                            String emailInput = _loginController.text.trim();

                            showDialog(
                              context: context,
                              builder: (context) {
                                // ใช้ TextEditingController แยกสำหรับ Popup เผื่อผู้ใช้ยังไม่ได้พิมพ์ Email ข้างนอก
                                final resetEmailController = TextEditingController(text: emailInput.contains('@') ? emailInput : '');

                                return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text("Forgot Password", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkColor)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Enter your email address and we'll send you a link to reset your password.", style: GoogleFonts.poppins(fontSize: 13, color: subTextColor)),
                                      const SizedBox(height: 15),
                                      TextField(
                                        controller: resetEmailController,
                                        decoration: InputDecoration(
                                          hintText: "Email address",
                                          hintStyle: GoogleFonts.poppins(fontSize: 14, color: subTextColor),
                                          prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                                          filled: true,
                                          fillColor: const Color(0xFFF5F5F5),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancel", style: GoogleFonts.poppins(color: subTextColor, fontWeight: FontWeight.w600)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        String email = resetEmailController.text.trim();
                                        if (email.isEmpty || !email.contains('@')) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email address.')));
                                          return;
                                        }

                                        Navigator.pop(context); // ปิด Popup
                                        try {
                                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Password reset email sent! Please check your inbox.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                          }
                                        }
                                      },
                                      child: Text("Send Link", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            child: Text("LOG IN", style: buttonTextStyle),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Center(
                          child: Text(
                            "Or log in with",
                            style: bodyTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialLoginButton(
                              imagePath: "lib/images/google_logo.png",
                              fallbackIcon: Icons.g_mobiledata,
                              color: Colors.red,
                              onTap: _signInWithGoogle, 
                            ),
                            const SizedBox(width: 20),
                            _SocialLoginButton(
                              imagePath: "lib/images/facebook_logo.png",
                              fallbackIcon: Icons.facebook,
                              color: Colors.blue,
                              onTap: _signInWithFacebook, 
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: bodyTextStyle),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Register",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 100),

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

// 🟢 เปลี่ยนจาก StatelessWidget เป็น StatefulWidget
class _CustomInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool showForgotPassword;
  final VoidCallback? onForgotPasswordPressed;
  final TextEditingController? controller;

  const _CustomInputField({
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.showForgotPassword = false,
    this.onForgotPasswordPressed,
    this.controller,
  });

  @override
  State<_CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<_CustomInputField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นช่องรหัสผ่าน ให้เริ่มต้นด้วยการซ่อน (true)
    _isObscured = widget.isPassword; 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: labelTextStyle),
            if (widget.showForgotPassword)
              GestureDetector(
                onTap: widget.onForgotPasswordPressed,
                child: Text(
                  "Forgot your password?",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _isObscured, // 🟢 ซ่อนหรือโชว์รหัสตาม State
          style: TextStyle(color: darkColor),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: bodyTextStyle.copyWith(color: subTextColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            // 🟢 เช็คว่าถ้าเป็นช่องรหัสผ่าน ให้แสดงปุ่มลูกตาเปิด/ปิด
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured; // สลับสถานะเปิดปิด
                      });
                    },
                  )
                : Icon(widget.icon, color: primaryColor),
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
  final VoidCallback onTap; 

  const _SocialLoginButton({
    required this.imagePath,
    required this.fallbackIcon,
    required this.color,
    required this.onTap, 
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
        onTap: onTap, 
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