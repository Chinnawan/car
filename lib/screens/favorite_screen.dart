import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constant/my_constant.dart';
import '../data/car_model.dart';
import 'product_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<CarModel> _allCars = [];
  bool _isLoadingCars = true;
  String currentUserEmail = "";

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? "";
    fetchCarsFromFirestore();
  }

  // ดึงข้อมูลรถทั้งหมดมาเตรียมไว้ เพื่อให้เวลากดดูรายละเอียดส่งข้อมูลไป ProductScreen ได้ครบถ้วน
  Future<void> fetchCarsFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('product').get();
      List<CarModel> loadedCars = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> carData = {
          "name": data['title'] ?? data['name'] ?? '',
          "licensePlate": data['licensePlate'] ?? '',
          "imagePath": data['image'] ?? data['imagePath'] ?? '',
          "price": data['priceText'] ?? data['price']?.toString() ?? '',
          "category": data['category'] ?? 'All',
          "description": data['description'] ?? 'ไม่มีคำอธิบายเพิ่มเติมสำหรับรถคันนี้',
          "modelYear": data['modelYear'] ?? '-',
          "horsePower": data['horsePower'] ?? '-',
          "transmission": data['transmission'] ?? '-',
        };
        loadedCars.add(CarModel.fromJson(carData));
      }
      if (mounted) {
        setState(() {
          _allCars = loadedCars;
          _isLoadingCars = false;
        });
      }
    } catch (e) {
      print("Error fetching cars: $e");
      if (mounted) setState(() => _isLoadingCars = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "My Favorites",
          style: GoogleFonts.poppins(color: darkColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // เอาปุ่ม Back ออกเพราะหน้านี้อยู่ใน Nav Bar
      ),
      body: _isLoadingCars
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('favorites')
                  .where('userEmail', isEqualTo: currentUserEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins()));
                }

                // ดึงรายชื่อรถที่กดหัวใจไว้
                List<String> favoriteCarNames = snapshot.data!.docs
                    .map((doc) => (doc.data() as Map<String, dynamic>)['carName'] as String)
                    .toList();

                // กรองเฉพาะรถที่มีชื่อตรงกับในหน้า Favorites
                List<CarModel> favoriteCars = _allCars
                    .where((car) => favoriteCarNames.contains(car.name))
                    .toList();

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Let's find your",
                          style: GoogleFonts.poppins(fontSize: 24, color: darkColor),
                        ),
                        Text(
                          "favorite car",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // แสดงข้อมูลรถ หรือแจ้งเตือนถ้ายังไม่มีรถใน Favorites
                        if (favoriteCars.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 50),
                                Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 15),
                                Text(
                                  "No favorite cars yet",
                                  style: GoogleFonts.poppins(fontSize: 18, color: subTextColor),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: favoriteCars.length,
                            itemBuilder: (context, index) {
                              final car = favoriteCars[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductScreen(car: car),
                                    ),
                                  );
                                },
                                child: _CarCard(
                                  name: car.name,
                                  licensePlate: car.licensePlate,
                                  imagePath: car.imagePath,
                                  price: car.price,
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Widget การ์ดรถที่ถอด Hero ออก ป้องกันบั๊กแอนิเมชันชนกันตอนสลับแท็บ
class _CarCard extends StatelessWidget {
  final String name;
  final String licensePlate;
  final String imagePath;
  final String price;

  const _CarCard({
    required this.name,
    required this.licensePlate,
    required this.imagePath,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              height: 220,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: subTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        licensePlate,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}