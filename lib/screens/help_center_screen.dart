import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/my_constant.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  // 🟢 ฟังก์ชันสำหรับเปิดลิงก์ Facebook (หรือลิงก์อื่นๆ)
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // title: Text(
        //   "Help Center",
        //   style: GoogleFonts.poppins(
        //     fontWeight: FontWeight.bold,
        //     fontSize: 18,
        //     color: darkColor,
        //   ),
        // ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // 🟢 ภาพ Graphic หรือ Icon ด้านบน
            Icon(Icons.support_agent, size: 100, color: primaryColor),
            const SizedBox(height: 20),
            Text(
              "How can we help you?",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "If you have any issues with our service,\nfeel free to contact us anytime.",
              style: GoogleFonts.poppins(fontSize: 14, color: subTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 🟢 รายการช่องทางการติดต่อ
            _buildContactCard(
              context,
              icon: Icons.phone_in_talk,
              title: "Call Center",
              subtitle: "02-669-6969",
              iconColor: Colors.green,
              onTap: () => _launchURL('tel:020000000'), // กดแล้วเด้งไปหน้าโทรออก
            ),
            _buildContactCard(
              context,
              icon: Icons.facebook,
              title: "Facebook Page",
              subtitle: "Car.Hub Official",
              iconColor: Colors.blue,
              onTap: () => _launchURL('https://www.facebook.com/Chinnawan05'), // 🟢 ใส่ลิงก์เพจจริงตรงนี้
            ),
            _buildContactCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: "LINE Official",
              subtitle: "@Car.Hub",
              iconColor: const Color(0xFF00B900), // สีเขียว LINE
              onTap: () => _launchURL('https://line.me/R/'), // 🟢 ใส่ลิงก์ LINE ตรงนี้
            ),
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "support@carhub.com",
              iconColor: Colors.orange,
              onTap: () => _launchURL('mailto:support@carhub.com'), // กดแล้วเด้งไปหน้าส่งอีเมล
            ),
            
            const SizedBox(height: 20),
            
            // 🟢 เพิ่มข้อมูลเวลาทำการ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: subTextColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Working Hours: Mon - Sun, 09:00 - 18:00",
                    style: GoogleFonts.poppins(fontSize: 12, color: subTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 Widget สร้างปุ่มกดแต่ละอันให้สวยงาม
  Widget _buildContactCard(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, color: subTextColor),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: darkColor
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
        onTap: onTap,
      ),
    );
  }
}