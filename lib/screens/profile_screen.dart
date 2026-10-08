import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';

import '../constant/my_constant.dart';
import 'login_screen.dart';
import 'admin_screen.dart';
import 'order_screen.dart';
import 'my_bookings_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayUsername = "Loading...";
  String displayEmail = "";
  String? photoUrl;
  String? photoBase64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String tempName = "Unknown User";
      String? tempBase64;

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          if (doc.data()!.containsKey('username')) {
            tempName = doc.data()!['username'];
          }
          if (doc.data()!.containsKey('photoBase64')) {
            tempBase64 = doc.data()!['photoBase64'];
          }
        }
      } catch (e) {
        // Handle error if needed
      }

      if (tempName == "Unknown User" &&
          user.displayName != null &&
          user.displayName!.isNotEmpty) {
        tempName = user.displayName!;
      } else if (tempName == "Unknown User" && user.email != null) {
        tempName = user.email!.split('@')[0];
      }

      String? finalPhotoUrl;
      for (var providerInfo in user.providerData) {
        if (providerInfo.providerId == 'google.com' &&
            providerInfo.photoURL != null) {
          finalPhotoUrl = providerInfo.photoURL;
          if (finalPhotoUrl!.contains('=s96-c')) {
            finalPhotoUrl = finalPhotoUrl.replaceAll('=s96-c', '=s400-c');
          }
          break;
        } else if (providerInfo.providerId == 'facebook.com' &&
            providerInfo.photoURL != null) {
          finalPhotoUrl = providerInfo.photoURL;
          if (finalPhotoUrl!.contains('?')) {
            finalPhotoUrl = "$finalPhotoUrl&type=large&width=500&height=500";
          } else {
            finalPhotoUrl = "$finalPhotoUrl?type=large&width=500&height=500";
          }
          break;
        }
      }
      finalPhotoUrl ??= user.photoURL;

      if (mounted) {
        setState(() {
          displayUsername = tempName;
          displayEmail = user.email ?? "";
          photoBase64 = tempBase64;
          photoUrl = finalPhotoUrl;
        });
      }
    } else {
      // 🟢 เพิ่มส่วนนี้: กรณีที่ยังไม่ได้ Login (Guest)
      if (mounted) {
        setState(() {
          displayUsername = "Guest";
          displayEmail = "Please log in to use all features";
          photoUrl = null;
          photoBase64 = null;
        });
      }
    }
  }

  // 🟢 ฟังก์ชันสำหรับเปิด Popup Edit Profile
  void _openEditProfilePopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ทำให้ Popup ดันขึ้นตามคีย์บอร์ดได้
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileBottomSheet(
        currentName: displayUsername,
        currentEmail: displayEmail,
        photoBase64: photoBase64,
        photoUrl: photoUrl,
      ),
    ).then((isUpdated) {
      // ถ้ายืนยันการแก้ไข ให้ดึงข้อมูลใหม่
      if (isUpdated == true) {
        _loadUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 1. เช็คสถานะ Social Login ตั้งแต่ตอนเริ่มสร้างหน้าจอ
    final user = FirebaseAuth.instance.currentUser;
    bool isSocialLogin = user?.providerData.any(
          (info) =>
              info.providerId == 'google.com' ||
              info.providerId == 'facebook.com',
        ) ??
        false;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- 1. Header Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "My Profile",
                        style: subHeaderTextStyle.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: secondaryColor, width: 2),
                          color: lightColor,
                        ),
                        child: ClipOval(
                          child:
                              (photoBase64 != null && photoBase64!.isNotEmpty)
                              ? Image.memory(
                                  base64Decode(photoBase64!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        'lib/images/profile.png',
                                        fit: BoxFit.cover,
                                      ),
                                )
                              : (photoUrl != null && photoUrl!.isNotEmpty)
                              ? Image.network(
                                  photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        'lib/images/profile.png',
                                        fit: BoxFit.cover,
                                      ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                )
                              : Image.asset(
                                  'lib/images/profile.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, size: 16, color: lightColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Text(
                    displayUsername,
                    style: subHeaderTextStyle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  if (displayEmail.isNotEmpty)
                    Text(
                      displayEmail,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),

            // --- 2. Menu Section ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // เมนูสำหรับ Admin
                      if (user != null && displayEmail == 'admin@email.com') ...[
                        _buildSectionHeader("SYSTEM & ADMIN"),
                        _buildMenuItem(
                          icon: Icons.directions_car_outlined,
                          text: "Vehicle Management",
                          subtitle: "Adding, deleting, and editing vehicle.",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminScreen())),
                        ),
                        _buildMenuItem(
                          icon: Icons.receipt_long,
                          text: "Manage Car Orders",
                          subtitle: "View all vehicle booking orders.",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderScreen())),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 🟢 ซ่อนเมนูส่วนตัว ถ้ายังไม่ได้ Login (Guest)
                      if (user != null) ...[
                        _buildSectionHeader("IDENTITY & VERIFICATION"),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          text: "Edit Profile",
                          onTap: _openEditProfilePopup,
                        ),
                        if (!isSocialLogin)
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            text: "Reset Password",
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text("Change Password", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                  content: Text("We will send a password reset link to your email: ${user.email}", style: GoogleFonts.poppins()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        try {
                                          await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset email sent!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                                          }
                                        } catch (e) {
                                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                        }
                                      },
                                      child: Text("Send Link", style: GoogleFonts.poppins(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 20),

                        // เมนูประวัติการจอง (ซ่อนจาก Guest เช่นกัน)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('orders')
                              .where('userEmail', isEqualTo: user.email)
                              .snapshots(),
                          builder: (context, snapshot) {
                            int activeCount = 0;
                            int historyCount = 0;

                            if (snapshot.hasData) {
                              for (var doc in snapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                final status = (data['status'] ?? 'pending').toString().toLowerCase();

                                if (status == 'success' || status == 'cancel' || status == 'cancelled' || status == 'rejected') {
                                  historyCount++;
                                } else if (status == 'pending' || status == 'approved' || status == 'paid') {
                                  activeCount++;
                                }
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader("MY BOOKINGS"),
                                _buildMenuItem(
                                  icon: Icons.history,
                                  text: "Rental History",
                                  badgeCount: historyCount,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen(isHistory: true))),
                                ),
                                _buildMenuItem(
                                  icon: Icons.car_rental,
                                  text: "Active Bookings",
                                  badgeCount: activeCount,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen(isHistory: false))),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ], // จบเงื่อนไข if (user != null)

                      // 🟢 เมนู Support (Guest ก็ดูได้)
                      _buildSectionHeader("SUPPORT & OTHERS"),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        text: "Help Center & FAQ",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen())),
                      ),
                      _buildMenuItem(
                        icon: Icons.policy_outlined,
                        text: "Terms & Privacy Policy",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),

                      // 🟢 ปุ่มเปลี่ยนเป็น Log In / Log Out อัตโนมัติ
                      InkWell(
                        onTap: () async {
                          if (user != null) {
                            await FirebaseAuth.instance.signOut();
                          }
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (user != null ? Colors.red : primaryColor).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  user != null ? Icons.logout : Icons.login,
                                  color: user != null ? Colors.red : primaryColor,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                user != null ? "Log Out" : "Log In",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: user != null ? Colors.red : primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: subTextColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    String? subtitle,
    bool isVerified = false,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 24),
        ),
        title: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12, color: subTextColor),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isVerified)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  "Verified",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// 🟢 Widget ส่วนของ Popup Bottom Sheet (แก้โปรไฟล์สไตล์ iOS)
// =========================================================
class _EditProfileBottomSheet extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String? photoBase64;
  final String? photoUrl;

  const _EditProfileBottomSheet({
    required this.currentName,
    required this.currentEmail,
    this.photoBase64,
    this.photoUrl,
  });

  @override
  State<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _isLoading = false;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // 🟢 สั่งบีบอัดรูปและลดขนาดตั้งแต่ตอนเลือกเลย
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth:
          800, // ลดความกว้างสูงสุดไม่เกิน 800px (เพียงพอมากสำหรับรูปโปรไฟล์)
      maxHeight: 800, // ลดความสูงสูงสุดไม่เกิน 800px
      imageQuality:
          70, // ลดคุณภาพไฟล์เหลือ 70% (ตาเปล่ามองแทบไม่ออก แต่ไฟล์เล็กลงเยอะมาก)
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

      if (mounted) {
        final croppedBytes = await showDialog<Uint8List>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _CropImageDialog(imageBytes: bytes),
        );

        if (croppedBytes != null) {
          setState(() {
            _pickedImageBytes = croppedBytes;
          });
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? base64Image = widget.photoBase64;
      if (_pickedImageBytes != null) {
        base64Image = base64Encode(_pickedImageBytes!);
      }

      await user.updateDisplayName(_nameController.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': _nameController.text.trim(),
        'photoBase64': base64Image,
        'email': user.email,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context, true); // ปิด Popup พร้อมส่งค่าว่าอัปเดตสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 ใช้ Padding กันคีย์บอร์ดบัง
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ที่จับสไลด์ลง
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Edit Profile",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 30),

              // 🟢 รูปรถตรงกลาง (คล้ายๆ UI ที่ส่งมา)
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _pickedImageBytes != null
                            ? Image.memory(
                                _pickedImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : (widget.photoBase64 != null &&
                                  widget.photoBase64!.isNotEmpty)
                            ? Image.memory(
                                base64Decode(widget.photoBase64!),
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              )
                            : (widget.photoUrl != null &&
                                  widget.photoUrl!.isNotEmpty)
                            ? Image.network(
                                widget.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: darkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 🟢 การ์ดข้อมูลสไตล์ iOS
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- Name Row ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Name",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: darkColor,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.edit, size: 14, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                    const Divider(height: 1, indent: 20),
                    // --- Email Row (ReadOnly) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Email",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              _emailController.text,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                          ), // ดันให้ตรงกับ Name ด้านบนนิดนึง
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🟢 ปุ่ม Save
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Save",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 🟢 Custom Widget สำหรับ Popup Crop รูปภาพ
// ==========================================
class _CropImageDialog extends StatefulWidget {
  final Uint8List imageBytes;
  const _CropImageDialog({required this.imageBytes});

  @override
  State<_CropImageDialog> createState() => _CropImageDialogState();
}

class _CropImageDialogState extends State<_CropImageDialog> {
  final _cropController = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  "Crop photo",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: subTextColor, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Crop(
                      image: widget.imageBytes,
                      controller: _cropController,
                      onCropped: (dynamic result) {
                        Future.delayed(Duration.zero, () {
                          if (mounted) {
                            Uint8List? croppedData;
                            try {
                              if (result is Uint8List) {
                                croppedData = result;
                              } else {
                                croppedData = result.croppedImage;
                              }
                            } catch (e) {
                              print("Crop error: $e");
                            }
                            Navigator.pop(context, croppedData);
                          }
                        });
                      },
                      aspectRatio: 1 / 1,
                      withCircleUi: true,
                      baseColor: Colors.transparent,
                      maskColor: Colors.black.withOpacity(0.6),
                      radius: 20,
                    ),
                    if (_isCropping)
                      Container(
                        color: Colors.white.withOpacity(0.6),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Pinch to zoom & drag to move",
              style: GoogleFonts.poppins(fontSize: 12, color: subTextColor),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isCropping
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        color: _isCropping ? Colors.grey : subTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_isCropping) return;
                      setState(() => _isCropping = true);
                      _cropController.crop();
                    },
                    child: Text(
                      "Crop",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
