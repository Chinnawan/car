import 'package:flutter/material.dart';
import '../constant/my_constant.dart'; 

import 'home_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart'; // 🟢 เอา import wallet_screen.dart ออกไปแล้ว

class MainScreen extends StatefulWidget {
  final bool showLoginSuccessPopup;
  final int initialIndex;

  const MainScreen({
    super.key, 
    this.showLoginSuccessPopup = false,
    this.initialIndex = 0, 
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // 🟢 เหลือแค่ 3 หน้า
    _screens = [
      HomeScreen(showLoginSuccessPopup: widget.showLoginSuccessPopup),
      const FavoriteScreen(),
      const ProfileScreen(), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 ปรับฟังก์ชันเช็คสีพื้นหลังให้ตรงกับ Index ใหม่
    Color getBackgroundColor() {
      if (_currentIndex == 0 || _currentIndex == 1) {
        return const Color(0xFFF5F5F5); // พื้นหลังเทาสำหรับหน้า Home และ Favorite
      } else {
        return lightColor; // พื้นหลังขาวสำหรับหน้า Profile (ตอนนี้คือ Index 2)
      }
    }

    return Scaffold(
      backgroundColor: getBackgroundColor(), 
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 🟢 จัดการปุ่มให้เหลือ 3 ปุ่ม และปรับ Index ให้เรียงกัน
            _buildNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, index: 0),
            _buildNavItem(icon: Icons.favorite_border, activeIcon: Icons.favorite, index: 1),
            _buildNavItem(icon: Icons.person_outline, activeIcon: Icons.person, index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required IconData activeIcon, required int index}) {
    bool isActive = _currentIndex == index;
    return IconButton(
      icon: Icon(
        isActive ? activeIcon : icon, 
        color: isActive ? primaryColor : subTextColor, 
        size: 30,
      ),
      onPressed: () {
        setState(() {
          _currentIndex = index; 
        });
      },
    );
  }
}