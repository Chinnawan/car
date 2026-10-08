import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';    
import '../constant/my_constant.dart';
import '../data/car_model.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final CarModel car;
  final String customerName;  
  final String customerPhone; 

  const PaymentScreen({
    super.key, 
    required this.car,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; 
  bool _isLoading = false; 

  Future<void> _processPaymentAndSaveOrder() async {
    setState(() {
      _isLoading = true; 
    });

    try {
      String orderId = "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
      
      String paymentMethodStr = _selectedMethod == 0 ? "PromptPay" : _selectedMethod == 1 ? "Credit Card" : "Mobile Banking";
      
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? "Guest";

      Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userEmail': userEmail,
        'customerName': widget.customerName,
        'customerPhone': widget.customerPhone,
        'carName': widget.car.name,
        'licensePlate': widget.car.licensePlate,
        'depositAmount': 5000,
        'paymentMethod': paymentMethodStr,
        'status': 'Pending', 
        'orderDate': FieldValue.serverTimestamp(),
        'imagePath': widget.car.imagePath, 
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      await FirebaseFirestore.instance.collection('notifications').add({
        'userEmail': userEmail,
        'carName': widget.car.name,
        'orderId': orderId,
        'status': 'Pending', 
        'timestamp': FieldValue.serverTimestamp(), 
        'isRead': false, // 🟢 เพิ่มบรรทัดนี้! บั๊กกระดิ่งไม่ขึ้นเลขแดงจะหายไป
      });

      if (mounted) {
        Navigator.pushReplacement( 
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              carName: widget.car.name,
              orderId: orderId, 
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Payment", style: GoogleFonts.poppins(color: darkColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // 🟢 1. แสดงชื่อรุ่นรถที่กำลังจะจอง
                  Text("Vehicle", style: GoogleFonts.poppins(fontSize: 14, color: subTextColor)),
                  Text(widget.car.name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: darkColor), textAlign: TextAlign.center,),
                  const SizedBox(height: 15),

                  Text("Booking Deposit", style: GoogleFonts.poppins(fontSize: 14, color: subTextColor)),
                  Text("฿5,000", style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🟢 2. แสดง Contact ที่กรอกมาจากหน้า Checkout
            Text("Contact Information", style: labelTextStyle),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: subTextColor, size: 20),
                      const SizedBox(width: 10),
                      Text(widget.customerName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: darkColor)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, color: subTextColor, size: 20),
                      const SizedBox(width: 10),
                      Text(widget.customerPhone, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: darkColor)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            
            Text("Select Payment Method", style: labelTextStyle),
            const SizedBox(height: 20),

            _buildPaymentOption(0, Icons.qr_code_2, "PromptPay QR"),
            _buildPaymentOption(1, Icons.credit_card, "Credit / Debit Card"),
            _buildPaymentOption(2, Icons.account_balance, "Mobile Banking"),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPaymentAndSaveOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text("Confirm Payment", style: buttonTextStyle),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int index, IconData icon, String title) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : subTextColor, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : darkColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor),
          ],
        ),
      ),
    );
  }
}