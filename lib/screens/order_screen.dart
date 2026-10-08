import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // 🟢 เพิ่ม Font
import '../constant/my_constant.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending": return Colors.orange;
      case "approved":
      case "paid":
      case "success": return Colors.green;
      case "cancel":
      case "cancelled":
      case "rejected": return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> updateStatus(String docId, String status, Map<String, dynamic> orderData) async {
    await FirebaseFirestore.instance.collection('orders').doc(docId).update({"status": status});
    await FirebaseFirestore.instance.collection('notifications').add({
      'userEmail': orderData['userEmail'] ?? '',
      'carName': orderData['carName'] ?? '',
      'orderId': orderData['orderId'] ?? '',
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false, 
    });
  }

  void confirmAction(BuildContext context, String docId, String status, String title, Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkColor)),
        content: Text("Are you sure you want to proceed?", style: GoogleFonts.poppins(color: subTextColor)),
        actions: [
          TextButton(
            child: Text("Cancel", style: GoogleFonts.poppins(color: subTextColor, fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == "Cancel" ? Colors.red : primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Confirm", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(context); 
              updateStatus(docId, status, orderData); 
            },
          ),
        ],
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(title, style: GoogleFonts.poppins(fontSize: 12, color: subTextColor)),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, color: darkColor, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right, // 🟢 ชิดขวาเหมือนใบเสร็จ
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 🟢 สีพื้นหลังคลีนๆ
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Manage Orders", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: darkColor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryColor));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No orders found", style: GoogleFonts.poppins(fontSize: 18, color: subTextColor)));

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? "Pending";
              
              Color statusColor = getStatusColor(status);
              Color statusBgColor = statusColor.withOpacity(0.1);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(25), // 🟢 โค้ง 25 ให้เข้ากับหน้าอื่นๆ
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🟢 Header (Order ID และ ป้าย Status)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['orderId'] ?? '',
                          style: GoogleFonts.poppins(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.poppins(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ),

                    // 🟢 ชื่อรถ
                    Text(
                      data['carName'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor),
                    ),
                    const SizedBox(height: 15),

                    // 🟢 กล่องรายละเอียด (แบบเดียวกับหน้า Bookings)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          infoRow("Customer", data['customerName'] ?? ''),
                          infoRow("Phone", data['customerPhone'] ?? ''),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ),
                          infoRow("License", data['licensePlate'] ?? ''),
                          infoRow("Payment", data['paymentMethod'] ?? ''),
                          infoRow("Deposit", "฿${data['depositAmount']}"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 🟢 ส่วนแสดงปุ่มของ Admin
                    if (status.toLowerCase() == "pending")
                      Row(
                        children: [
                          // ปุ่ม Confirm
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => confirmAction(context, doc.id, "Approved", "Approve Booking?", data),
                              child: Text("Approve", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // ปุ่ม Cancel
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => confirmAction(context, doc.id, "Cancel", "Cancel Booking?", data),
                              child: Text("Reject", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    else if (status.toLowerCase() == "approved")
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor, 
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () => confirmAction(context, doc.id, "Success", "Customer received the car?", data),
                          child: Text("Mark as Picked Up", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}