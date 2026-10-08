import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constant/my_constant.dart';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const BookingDetailScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    // 🟢 ดึงข้อมูลต่างๆ ออกมาเตรียมไว้
    String carName = orderData['carName'] ?? 'Unknown Car';
    String imagePath = orderData['imagePath'] ?? orderData['image'] ?? '';
    String orderId = orderData['orderId'] ?? '#ORD-???';
    String customerName = orderData['customerName'] ?? '-';
    String customerPhone = orderData['customerPhone'] ?? '-';
    String licensePlate = orderData['licensePlate'] ?? '-';
    String paymentMethod = orderData['paymentMethod'] ?? '-';
    String depositAmount = orderData['depositAmount']?.toString() ?? '0';
    String status = orderData['status'] ?? 'Pending';

    // 🟢 จัดการสี Status
    String statusLower = status.toLowerCase();
    Color statusColor;
    Color statusBgColor;

    if (statusLower == 'pending') {
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withOpacity(0.1);
    } else if (statusLower == 'approved' || statusLower == 'success') {
      statusColor = Colors.green;
      statusBgColor = Colors.green.withOpacity(0.1);
    } else if (statusLower == 'rejected' || statusLower == 'cancelled' || statusLower == 'cancel') {
      statusColor = Colors.red;
      statusBgColor = Colors.red.withOpacity(0.1);
    } else {
      statusColor = Colors.grey;
      statusBgColor = Colors.grey.withOpacity(0.1);
    }

    // 🟢 จัดการเวลา
    Timestamp? t = orderData['orderDate'] as Timestamp?;
    String dateDisplay = "รอระบุเวลา";
    if (t != null) {
      DateTime date = t.toDate();
      List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      String timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      dateDisplay = "${date.day} ${months[date.month - 1]} ${date.year}, $timeStr";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Booking Detail",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: darkColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 🟢 ส่วนบน: รูปรถและชื่อรถ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (imagePath.isNotEmpty)
                    Image.asset(imagePath, height: 150, fit: BoxFit.contain)
                  else
                    Icon(Icons.directions_car, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text(
                    carName,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    licensePlate,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🟢 ส่วนล่าง: ตั๋ว Voucher (QR Code และข้อมูล)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // จำลอง QR Code ไว้ให้พนักงานสแกน
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.qr_code_2, size: 120, color: darkColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    orderId,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2, // ถ่างตัวอักษรให้ดูเหมือนรหัส
                      color: subTextColor,
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),

                  // ข้อมูลต่างๆ
                  _buildInfoRow("Booking Date", dateDisplay),
                  _buildInfoRow("Customer Name", customerName),
                  _buildInfoRow("Phone Number", customerPhone),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                  _buildInfoRow("Payment Method", paymentMethod),
                  _buildInfoRow("Deposit Paid", "฿$depositAmount"),
                  
                  const SizedBox(height: 20),
                  
                  // ป้าย Status แบบใหญ่
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "STATUS: ${status.toUpperCase()}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🟢 Widget สำหรับสร้างบรรทัดข้อมูลคู่กัน (ซ้าย-ขวา)
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: subTextColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: darkColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}