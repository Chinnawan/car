import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constant/my_constant.dart';
import '../data/car_model.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CarModel car;

  const CheckoutScreen({super.key, required this.car});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 180, 
                  padding: const EdgeInsets.only(top: 20),
                  child: Hero(
                    tag: widget.car.imagePath, 
                    child: Image.asset(
                      widget.car.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Summary",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                          const SizedBox(height: 15),

                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.car.name,
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        "License Plate: ${widget.car.licensePlate}",
                                        style: GoogleFonts.poppins(fontSize: 12, color: subTextColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  widget.car.price,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),
                          Text("Contact Information", style: labelTextStyle),
                          const SizedBox(height: 10),

                          _buildTextField(_nameController, "Full Name", Icons.person_outline),
                          const SizedBox(height: 15),
                          // 🟢 ส่ง TextInputType.phone ไปเพื่อให้คีย์บอร์ดเด้งเป็นตัวเลข
                          _buildTextField(_phoneController, "Phone Number", Icons.phone_outlined, inputType: TextInputType.phone),

                          const SizedBox(height: 25),
                          
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.05),
                              border: Border.all(color: primaryColor.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Deposit",
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: darkColor),
                                ),
                                Text(
                                  "฿5,000",
                                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                String phone = _phoneController.text.trim();

                                // 1. เช็คว่ากรอกครบไหม
                                if (_nameController.text.isEmpty || phone.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                // 🟢 2. เช็คเบอร์โทร (ต้องเป็นตัวเลข 10 หลัก)
                                if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text("Invalid Phone Number", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                                      content: Text("กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง (ตัวเลข 10 หลัก)", style: GoogleFonts.poppins()),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("OK", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  );
                                  return; // หยุดการทำงานถ้าเบอร์ผิด
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(
                                      car: widget.car,
                                      customerName: _nameController.text.trim(), 
                                      customerPhone: phone, 
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 5,
                              ),
                              child: Text("Confirm & Pay Deposit", style: buttonTextStyle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              top: 10,
              left: 20,
              child: CircleAvatar(
                backgroundColor: lightColor,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  color: darkColor,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 เพิ่มพารามิเตอร์ inputType เพื่อรับค่า Keyboard Type
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType, // ใช้ Keyboard Type ที่ส่งมา
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: subTextColor),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}