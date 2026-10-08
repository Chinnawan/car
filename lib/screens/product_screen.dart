import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🟢 เพิ่ม Import Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 🟢 เพิ่ม Import Firestore
import '../constant/my_constant.dart';
import '../data/car_model.dart';

import 'checkout_screen.dart';

class ProductScreen extends StatefulWidget {
  final CarModel car;

  const ProductScreen({super.key, required this.car});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  double _dragOffset = 0.0;
  
  // 🟢 เพิ่มตัวแปรสำหรับจัดการ Favorite
  bool _isFavorite = false;
  String? _favoriteDocId;
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? "";

  @override
  void initState() {
    super.initState();
    _checkIfFavorite(); // 🟢 ตรวจสอบสถานะ Favorite ตอนเปิดหน้านี้
  }

  // 🟢 ฟังก์ชันตรวจสอบว่าเคยถูกใจรถคันนี้ไว้หรือยัง
  Future<void> _checkIfFavorite() async {
    if (currentUserEmail.isEmpty) return;

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userEmail', isEqualTo: currentUserEmail)
          .where('carName', isEqualTo: widget.car.name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _isFavorite = true;
            _favoriteDocId = snapshot.docs.first.id; // เก็บ ID ไว้เผื่อกดลบ
          });
        }
      }
    } catch (e) {
      print("Error checking favorite: $e");
    }
  }

  // 🟢 ฟังก์ชันสำหรับกด Like / Unlike
  Future<void> _toggleFavorite() async {
    if (currentUserEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาล็อกอินเพื่อบันทึกรถคันโปรด')),
      );
      return;
    }

    // อัปเดต UI ทันทีเพื่อให้ผู้ใช้รู้สึกว่าแตะแล้วตอบสนองไว (Optimistic UI)
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        // ถ้าถูกใจ -> เพิ่มลง Firebase
        var docRef = await FirebaseFirestore.instance.collection('favorites').add({
          'userEmail': currentUserEmail,
          'carName': widget.car.name,
          'licensePlate': widget.car.licensePlate,
          'imagePath': widget.car.imagePath,
          'price': widget.car.price,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _favoriteDocId = docRef.id; // เก็บ ID ไว้เผื่อผู้ใช้กดเอาออก
      } else {
        // ถ้าเอาออก -> ลบจาก Firebase
        if (_favoriteDocId != null) {
          await FirebaseFirestore.instance.collection('favorites').doc(_favoriteDocId).delete();
          _favoriteDocId = null;
        } else {
          // เผื่อในกรณีที่ _favoriteDocId หายไป ให้ไปหาแล้วลบ
          var snapshot = await FirebaseFirestore.instance
              .collection('favorites')
              .where('userEmail', isEqualTo: currentUserEmail)
              .where('carName', isEqualTo: widget.car.name)
              .get();
          for (var doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }
      }
    } catch (e) {
      // ถ้า Error ให้เปลี่ยน UI กลับเป็นเหมือนเดิม
      setState(() {
        _isFavorite = !_isFavorite;
      });
      print("Error toggling favorite: $e");
    }
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
                Expanded(
                  flex: 4, 
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Hero(
                          tag: widget.car.imagePath,
                          child: Image.asset(
                            widget.car.imagePath,
                            fit: BoxFit.contain,
                            height: 250,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 5, 
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy > 0 || _dragOffset > 0) {
                        setState(() {
                          _dragOffset += details.delta.dy;
                        });
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (_dragOffset > 100 || details.primaryVelocity! > 500) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          _dragOffset = 0.0;
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: Matrix4.translationValues(0, _dragOffset, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 30),
                      decoration: BoxDecoration(
                        color: lightColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.car.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: darkColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        widget.car.licensePlate,
                                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                widget.car.price,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSpecItem(Icons.calendar_month, "Year", widget.car.modelYear),
                              _buildSpecItem(Icons.speed, "Power", widget.car.horsePower),
                              _buildSpecItem(Icons.settings, "Gear", widget.car.transmission),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Text(
                            "Description",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.car.description,
                            style: bodyTextStyle.copyWith(height: 1.6),
                          ),

                          const Spacer(),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => CheckoutScreen(car: widget.car),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      var begin = const Offset(0.0, 0.2);
                                      var end = Offset.zero;
                                      var curve = Curves.easeOutCubic;

                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                      var slideAnimation = animation.drive(tween);

                                      return SlideTransition(
                                          position: slideAnimation,
                                          child: child,
                                        );
                                    },
                                    transitionDuration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                "Buy Now",
                                style: buttonTextStyle.copyWith(fontSize: 18),
                              ),
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
            
            // 🟢 อัปเดตปุ่ม Favorite ตรงนี้
            Positioned(
              top: 10,
              right: 20,
              child: CircleAvatar(
                backgroundColor: lightColor,
                child: IconButton(
                  // 🟢 สลับไอคอนระหว่างทึบกับโปร่ง ตามสถานะ
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border, 
                    size: 20
                  ),
                  color: Colors.red,
                  onPressed: _toggleFavorite, // 🟢 เรียกใช้ฟังก์ชันสลับสถานะ
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: subTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: darkColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}