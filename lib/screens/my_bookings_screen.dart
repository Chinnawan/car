import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constant/my_constant.dart';

import 'booking_detail_screen.dart'; 

class MyBookingsScreen extends StatelessWidget {
  // 🟢 เพิ่มตัวแปรเช็คว่าเป็นหน้าประวัติ (History) หรือหน้ากำลังดำเนินการ (Active)
  final bool isHistory; 

  const MyBookingsScreen({super.key, this.isHistory = false}); // ค่าเริ่มต้นคือ Active

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        title: Text(
          isHistory ? "Rental History" : "Active Bookings", // 🟢 เปลี่ยนชื่อหัวข้อตามโหมด
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userEmail", isEqualTo: user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // 🟢 นำข้อมูลมากรอง (Filter) ตามโหมดที่เลือก
          var allDocs = snapshot.data!.docs.toList();
          var filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'pending').toString().toLowerCase();

            if (isHistory) {
              // โหมดประวัติ: โชว์เฉพาะที่จบงานแล้ว (รับรถแล้ว) หรือ ยกเลิก
              return status == 'success' || status == 'cancel' || status == 'cancelled' || status == 'rejected';
            } else {
              // โหมด Active: โชว์เฉพาะที่กำลังรอดำเนินการ หรือ อนุมัติแล้วรอไปรับรถ
              return status == 'pending' || status == 'approved' || status == 'paid';
            }
          }).toList();

          if (filteredDocs.isEmpty) {
            return _buildEmptyState();
          }

          // นำข้อมูลมาเรียงลำดับเวลาจากใหม่ไปเก่า
          filteredDocs.sort((a, b) {
            var dataA = a.data() as Map<String, dynamic>;
            var dataB = b.data() as Map<String, dynamic>;
            Timestamp? timeA = dataA['orderDate'] as Timestamp?;
            Timestamp? timeB = dataB['orderDate'] as Timestamp?;
            
            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1; 
            if (timeB == null) return -1;
            
            return timeB.compareTo(timeA); 
          });

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data() as Map<String, dynamic>;
              final String imagePath = data['imagePath'] ?? data['image'] ?? '';
              
              String status = data['status'] ?? 'Pending';
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

              Timestamp? t = data['orderDate'] as Timestamp?;
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

              // 🟢 เช็คว่ารายการนี้ถูกยกเลิกหรือยัง เพื่อนำไปใช้ซ่อนปุ่ม
              bool isCancelled = statusLower == 'cancel' || statusLower == 'cancelled' || statusLower == 'rejected';

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: subTextColor),
                            const SizedBox(width: 6),
                            Text(
                              dateDisplay,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 60, 
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5), 
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imagePath.isNotEmpty
                                ? Image.asset(
                                    imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                      color: subTextColor,
                                    ),
                                  )
                                : Icon(Icons.directions_car, color: subTextColor, size: 30),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['carName'] ?? 'Unknown Car',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['orderId'] ?? '#ORD-???',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9), 
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Customer", data['customerName'] ?? '-'),
                          _buildDetailRow("Phone", data['customerPhone'] ?? '-'),
                          _buildDetailRow("License", data['licensePlate'] ?? '-'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ),
                          _buildDetailRow("Payment", data['paymentMethod'] ?? '-'),
                          _buildDetailRow("Deposit", "฿${data['depositAmount'] ?? 0}"),
                        ],
                      ),
                    ),
                    
                    // 🟢 ซ่อนปุ่ม "View Voucher" ถ้ารถคันนี้โดน Cancel ไปแล้ว
                    if (!isCancelled) ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkColor, 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), 
                            ),
                            elevation: 0, 
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailScreen(orderData: data),
                              ),
                            );
                          },
                          child: Text(
                            statusLower == 'success' ? "View Receipt" : "View Voucher", // เปลี่ยนชื่อปุ่มถ้ารับรถแล้ว
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            )
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🟢 แยก Widget หน้าจอว่างๆ ออกมาเพื่อใช้ซ้ำ
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            isHistory ? "No rental history" : "No active bookings",
            style: GoogleFonts.poppins(fontSize: 18, color: subTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: subTextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
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