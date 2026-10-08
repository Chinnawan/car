import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constant/my_constant.dart';
import '../data/car_model.dart';

import 'profile_screen.dart';
import 'product_screen.dart';
import 'notification_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SortOption { recommended, priceLowToHigh, priceHighToLow, nameAZ }

class HomeScreen extends StatefulWidget {
  final bool showLoginSuccessPopup; // 🟢 เพิ่มตัวแปรสำหรับเช็คการแสดง Popup

  // 🟢 ตั้งค่าเริ่มต้นเป็น false ถ้าเปิดมาปกติจะไม่แสดง
  const HomeScreen({super.key, this.showLoginSuccessPopup = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CarModel> _carList = [];
  String _selectedCategory = 'All';
  SortOption _selectedSortOption = SortOption.recommended;

  @override
  void initState() {
    super.initState();

    // 🟢 เช็คว่าถ้าถูกส่งค่ามาเป็น true ถึงจะแสดง Popup
    if (widget.showLoginSuccessPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginSuccessPopup();
      });
    }

    fetchCarsFromFirestore();
  }

  Future<void> fetchCarsFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('product')
          .get();
      List<CarModel> loadedCars = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> carData = {
          "name": data['title'] ?? data['name'] ?? '',
          "licensePlate": data['licensePlate'] ?? '',
          "imagePath": data['image'] ?? data['imagePath'] ?? '',
          "price": data['priceText'] ?? data['price']?.toString() ?? '',
          "category": data['category'] ?? 'All',
          "description":
              data['description'] ?? 'ไม่มีคำอธิบายเพิ่มเติมสำหรับรถคันนี้',
          "modelYear": data['modelYear'] ?? '-',
          "horsePower": data['horsePower'] ?? '-',
          "transmission": data['transmission'] ?? '-',
        };
        loadedCars.add(CarModel.fromJson(carData));
      }
      setState(() {
        _carList = loadedCars;
      });
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการดึงข้อมูลจาก Firestore: $e");
    }
  }

  List<CarModel> get _filteredCars {
    if (_selectedCategory == 'All') {
      return _carList;
    } else {
      return _carList
          .where((car) => car.category == _selectedCategory)
          .toList();
    }
  }

  int _parsePrice(String priceString) {
    String cleanString = priceString.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanString) ?? 0;
  }

  String _getSortText(SortOption option) {
    switch (option) {
      case SortOption.recommended:
        return 'Recommended';
      case SortOption.priceLowToHigh:
        return 'Price: Low-High';
      case SortOption.priceHighToLow:
        return 'Price: High-Low';
      case SortOption.nameAZ:
        return 'Name (A-Z)';
    }
  }

  void _showLoginSuccessPopup() {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -100 * (1 - value)),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome back!",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "You have successfully logged in.",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry != null && overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<CarModel> displayCars = List.from(_filteredCars);

    switch (_selectedSortOption) {
      case SortOption.priceLowToHigh:
        displayCars.sort(
          (a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)),
        );
        break;
      case SortOption.priceHighToLow:
        displayCars.sort(
          (a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)),
        );
        break;
      case SortOption.nameAZ:
        displayCars.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.recommended:
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.grid_view_rounded, color: primaryColor),
          onPressed: () {},
        ),
        actions: [
          // 🟢 ดึงข้อมูลแจ้งเตือนที่ "ยังไม่ได้อ่าน" มาแสดงเป็นตัวเลข
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userEmail', isEqualTo: FirebaseAuth.instance.currentUser?.email ?? '')
                .where('isRead', isEqualTo: false) // ดึงเฉพาะที่ยังไม่ได้อ่าน
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }

              return IconButton(
                onPressed: () {
                  // พอกดให้เด้งไปหน้า Noti
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_outlined, color: primaryColor, size: 28),
                    // ถ้ามีข้อความใหม่ ให้แสดงจุดแดงพร้อมตัวเลข
                    if (unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Category",
                    style: labelTextStyle.copyWith(fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedCategory = 'All'),
                    child: Text(
                      "See all",
                      style: bodyTextStyle.copyWith(color: primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryCard(
                      icon: MdiIcons.carSports,
                      name: "Sport",
                      isSelected: _selectedCategory == "Sport",
                      onTap: () => setState(
                        () => _selectedCategory = _selectedCategory == "Sport"
                            ? "All"
                            : "Sport",
                      ),
                    ),
                    _CategoryCard(
                      icon: Icons.eco,
                      name: "Eco",
                      isSelected: _selectedCategory == "Eco Car",
                      onTap: () => setState(
                        () => _selectedCategory = _selectedCategory == "Eco Car"
                            ? "All"
                            : "Eco Car",
                      ),
                    ),
                    _CategoryCard(
                      icon: Icons.local_shipping,
                      name: "Truck",
                      isSelected: _selectedCategory == "Truck",
                      onTap: () => setState(
                        () => _selectedCategory = _selectedCategory == "Truck"
                            ? "All"
                            : "Truck",
                      ),
                    ),
                    _CategoryCard(
                      icon: Icons.two_wheeler,
                      name: "Motor",
                      isSelected: _selectedCategory == "Motorcycle",
                      onTap: () => setState(
                        () => _selectedCategory =
                            _selectedCategory == "Motorcycle"
                            ? "All"
                            : "Motorcycle",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Available Cars",
                    style: labelTextStyle.copyWith(fontSize: 18),
                  ),
                  PopupMenuButton<SortOption>(
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (SortOption result) =>
                        setState(() => _selectedSortOption = result),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<SortOption>>[
                          PopupMenuItem<SortOption>(
                            value: SortOption.recommended,
                            child: Text(
                              'Recommended',
                              style: bodyTextStyle.copyWith(color: darkColor),
                            ),
                          ),
                          PopupMenuItem<SortOption>(
                            value: SortOption.priceLowToHigh,
                            child: Text(
                              'Price: Low to High',
                              style: bodyTextStyle.copyWith(color: darkColor),
                            ),
                          ),
                          PopupMenuItem<SortOption>(
                            value: SortOption.priceHighToLow,
                            child: Text(
                              'Price: High to Low',
                              style: bodyTextStyle.copyWith(color: darkColor),
                            ),
                          ),
                          PopupMenuItem<SortOption>(
                            value: SortOption.nameAZ,
                            child: Text(
                              'Name (A-Z)',
                              style: bodyTextStyle.copyWith(color: darkColor),
                            ),
                          ),
                        ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: lightColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getSortText(_selectedSortOption),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: darkColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: darkColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _carList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : displayCars.isEmpty
                  ? Center(child: Text("No cars found", style: bodyTextStyle))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: displayCars.length,
                      itemBuilder: (context, index) {
                        final car = displayCars[index];
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
      ),
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.symmetric(vertical: 10),
      //   decoration: BoxDecoration(
      //     color: lightColor,
      //     borderRadius: const BorderRadius.only(
      //       topLeft: Radius.circular(30),
      //       topRight: Radius.circular(30),
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.grey.withOpacity(0.1),
      //         spreadRadius: 5,
      //         blurRadius: 10,
      //       ),
      //     ],
      //   ),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       IconButton(
      //         icon: Icon(Icons.home, color: primaryColor, size: 30),
      //         onPressed: () {},
      //       ),
      //       IconButton(
      //         icon: Icon(
      //           Icons.notifications_outlined,
      //           color: subTextColor,
      //           size: 30,
      //         ),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const NotificationScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //       IconButton(
      //         icon: Icon(Icons.wallet, color: subTextColor, size: 30),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (_) => const WalletScreen()),
      //           );
      //         },
      //       ),
      //       IconButton(
      //         icon: Icon(Icons.person_outline, color: subTextColor, size: 30),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const ProfileScreen(),
      //             ),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.name,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : lightColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? lightColor : darkColor, size: 32),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isSelected ? lightColor : darkColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              child: Hero(
                tag: imagePath,
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
