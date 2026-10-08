import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constant/my_constant.dart';
import 'main_screen.dart'; 
import 'my_bookings_screen.dart'; // 🟢 เพิ่มบรรทัดนี้เพื่อเชื่อมไปหน้า Booking

class SuccessScreen extends StatelessWidget {
  final String carName;
  final String orderId; 

  const SuccessScreen({
    super.key, 
    required this.carName,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 100),
                ),
              ),
              
              const SizedBox(height: 40),
              
              Text(
                "Payment Successful!",
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: darkColor),
              ),
              const SizedBox(height: 10),
              
              Text(
                "Order ID: $orderId",
                style: GoogleFonts.poppins(fontSize: 14, color: subTextColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              
              // 🟢 ทำให้ชื่อรถเด่นขึ้น
              Text(
                "Booked Vehicle:",
                style: GoogleFonts.poppins(fontSize: 14, color: subTextColor),
              ),
              Text(
                carName,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Text(
                "Your deposit has been received.\nOur sales team will contact you within 24 hours.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: subTextColor, height: 1.6),
              ),
              
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // 🟢 1. เคลียร์หน้าทั้งหมดแล้วกลับไปวางโครง MainScreen ไว้เป็นฐานก่อน
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                      (route) => false,
                    );
                    
                    // 🟢 2. เปิดหน้า Active Bookings ซ้อนทับขึ้นมา
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyBookingsScreen(isHistory: false)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  // 🟢 เปลี่ยนชื่อปุ่ม
                  child: Text("Go to Active Bookings", style: buttonTextStyle),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}