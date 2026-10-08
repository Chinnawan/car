import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constant/my_constant.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String currentUserEmail = "";
  
  // 🟢 ตัวแปรสำหรับจัดการ Animation การลบ
  bool _isClearing = false;
  final Map<String, bool> _slidingOutItems = {};

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? "";
    _markNotificationsAsRead();
  }

  Future<void> _markNotificationsAsRead() async {
    if (currentUserEmail.isEmpty) return;

    var unreadDocs = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userEmail', isEqualTo: currentUserEmail)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadDocs.docs) {
      doc.reference.update({'isRead': true});
    }
  }

  // 🟢 ฟังก์ชันลบทั้งหมดพร้อมแอนิเมชันไล่จากล่างขึ้นบน
  Future<void> _cleanAll(List<QueryDocumentSnapshot> docsToClean) async {
    if (_isClearing || docsToClean.isEmpty) return;
    
    setState(() {
      _isClearing = true;
    });

    // 1. สั่งให้เล่นแอนิเมชันสไลด์ไปทางซ้ายทีละอัน (ไล่จาก Index ล่างสุดขึ้นบนสุด)
    for (int i = docsToClean.length - 1; i >= 0; i--) {
      if (!mounted) break;
      setState(() {
        _slidingOutItems[docsToClean[i].id] = true;
      });
      // หน่วงเวลา 100ms ให้มันค่อยๆ สไลด์ตามกันไปเป็นคลื่น
      await Future.delayed(const Duration(milliseconds: 100)); 
    }

    // 2. รอให้อันสุดท้ายสไลด์จนสุดจอ
    await Future.delayed(const Duration(milliseconds: 250));

    // 3. สั่งลบข้อมูลออกจาก Firebase รวดเดียว
    for (var doc in docsToClean) {
      if (!mounted) break;
      await FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete();
    }

    if (mounted) {
      setState(() {
        _isClearing = false;
        _slidingOutItems.clear(); // ล้างสถานะทิ้ง
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // สีพื้นหลังเทาอ่อนๆ คลีนๆ
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            color: darkColor, // 🟢 เปลี่ยนสีตัวอักษรเป็นสีเข้ม
          ),
        ),
        backgroundColor: Colors.transparent, // 🟢 เปลี่ยนพื้นหลังให้โปร่งใสกลืนไปกับจอ
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkColor, size: 20), // 🟢 เปลี่ยนไอคอนกลับให้เข้าเซ็ต
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userEmail', isEqualTo: currentUserEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty && !_isClearing) { // เช็คด้วยว่าไม่ได้กำลังเล่นแอนิเมชันเคลียร์อยู่
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.poppins(fontSize: 18, color: subTextColor),
                  ),
                ],
              ),
            );
          }

          var sortedDocs = docs.toList();
          sortedDocs.sort((a, b) {
            Timestamp? timeA = (a.data() as Map)['timestamp'] as Timestamp? ??
                (a.data() as Map)['orderDate'] as Timestamp?;
            Timestamp? timeB = (b.data() as Map)['timestamp'] as Timestamp? ??
                (b.data() as Map)['orderDate'] as Timestamp?;
            if (timeA == null || timeB == null) return 0;
            return timeB.compareTo(timeA);
          });

          return Stack(
            children: [
              // 🟢 ตัว List การแจ้งเตือน
              ListView.builder(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 100), // เผื่อที่ด้านล่างให้ปุ่ม
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  var doc = sortedDocs[index];
                  var data = doc.data() as Map<String, dynamic>;

                  String carName = data['carName'] ?? 'Unknown Car';
                  String orderId = data['orderId'] ?? '#ORD-???';
                  String status = data['status'] ?? 'Pending';

                  Timestamp? t = data['timestamp'] as Timestamp? ??
                      data['orderDate'] as Timestamp?;
                  String timeDisplay = "Just now";

                  if (t != null) {
                    DateTime date = t.toDate();
                    DateTime now = DateTime.now();
                    DateTime today = DateTime(now.year, now.month, now.day);
                    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
                    DateTime aDate = DateTime(date.year, date.month, date.day);

                    String timeString =
                        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

                    if (aDate == today) {
                      timeDisplay = "Today\n$timeString";
                    } else if (aDate == yesterday) {
                      timeDisplay = "Yesterday\n$timeString";
                    } else {
                      int difference = today.difference(aDate).inDays;
                      timeDisplay = "$difference days ago\n$timeString";
                    }
                  }

                  String statusLower = status.toLowerCase();
                  String notificationTitle;
                  String notificationSubtitle = "";
                  Color statusColor;
                  Color statusBgColor;

                  if (statusLower == 'pending') {
                    notificationTitle = "Booking placed successfully";
                    notificationSubtitle = "Preparing your car";
                    statusColor = Colors.orange;
                    statusBgColor = Colors.orange.withOpacity(0.1);
                  } else if (statusLower == 'approved') {
                    notificationTitle = "Your car is approved";
                    notificationSubtitle = "Your car is ready. You can pick it up now!";
                    statusColor = Colors.green;
                    statusBgColor = Colors.green.withOpacity(0.1);
                  } else if (statusLower == 'rejected') {
                    notificationTitle = "Your booking was rejected";
                    notificationSubtitle = "Your car booking has been rejected!";
                    statusColor = Colors.red;
                    statusBgColor = Colors.red.withOpacity(0.1);
                  } else if (statusLower == 'cancelled' || statusLower == 'cancel') {
                    notificationTitle = "Booking status updated";
                    notificationSubtitle = "Your car booking has been cancelled!";
                    statusColor = const Color.fromARGB(255, 243, 33, 33);
                    statusBgColor = const Color.fromARGB(255, 243, 33, 33).withOpacity(0.1);
                  } else if (statusLower == 'success') {
                    notificationTitle = "Booking completed";
                    notificationSubtitle = "Thank you for using our service!";
                    statusColor = Colors.green;
                    statusBgColor = Colors.green.withOpacity(0.1);
                  } else {
                    notificationTitle = "Booking status updated";
                    notificationSubtitle = "Check your booking details.";
                    statusColor = Colors.grey;
                    statusBgColor = Colors.grey.withOpacity(0.1);
                  }

                  // 🟢 เช็คว่ารายการนี้กำลังถูกสั่งให้เลื่อนออกไปทางซ้ายหรือไม่
                  bool isSlidingOut = _slidingOutItems[doc.id] == true;

                  return AnimatedSlide(
                    offset: isSlidingOut ? const Offset(-1.5, 0) : Offset.zero, // เลื่อนไปทางซ้ายสุดจอ
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInBack, // โค้งแอนิเมชันให้ดูลื่นไหล
                    child: AnimatedOpacity(
                      opacity: isSlidingOut ? 0.0 : 1.0, // ค่อยๆ โปร่งใส
                      duration: const Duration(milliseconds: 300),
                      child: Dismissible(
                        key: Key(doc.id), 
                        direction: DismissDirection.endToStart, 
                        onDismissed: (direction) async {
                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .doc(doc.id)
                              .delete();
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(25), 
                          ),
                          alignment: Alignment.centerRight,
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        child: Container(
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  statusLower == 'approved' || statusLower == 'success'
                                      ? Icons.check_circle
                                      : Icons.directions_car,
                                  color: statusColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notificationTitle,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: darkColor,
                                      ),
                                    ),
                                    if (notificationSubtitle.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        notificationSubtitle,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Text(
                                      "Car: $carName",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Order ID: $orderId",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: subTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
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
                              ),
                              const SizedBox(width: 10),
                              Text(
                                timeDisplay,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.sarabun(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 🟢 ปุ่ม Clean All ด้านล่างตรงกลาง
              // if (sortedDocs.isNotEmpty || _isClearing)
              //   Positioned(
              //     bottom: 30,
              //     left: 0,
              //     right: 0,
              //     child: Center(
              //       child: SizedBox(
              //         width: 160,
              //         height: 50,
              //         child: ElevatedButton(
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: primaryColor, // สีน้ำตาล
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(25),
              //             ),
              //             elevation: 5,
              //           ),
              //           onPressed: _isClearing ? null : () => _cleanAll(sortedDocs),
              //           child: _isClearing
              //               ? const SizedBox(
              //                   width: 20,
              //                   height: 20,
              //                   child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              //                 )
              //               : Text(
              //                   "Clean All",
              //                   style: GoogleFonts.poppins(
              //                     fontSize: 16,
              //                     fontWeight: FontWeight.bold,
              //                     color: Colors.white, // ตัวหนังสือสีขาว
              //                   ),
              //                 ),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          );
        },
      ),
    );
  }
}