import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Color Palette (Coffee Theme) ---
// สีหลัก (ปุ่ม, หัวข้อ) - น้ำตาลเข้มแบบเมล็ดกาแฟ
Color primaryColor = const Color(0xFF6F4E37); 

// สีรอง (ส่วนตกแต่ง) - น้ำตาลอ่อนแบบลาเต้
Color secondaryColor = const Color(0xFFD7CCC8); 

// สีพื้นหลังหรือสีขาว
Color lightColor = const Color(0xFFFFFFFF);

// สีข้อความทั่วไป - เทาเข้มเกือบดำ
Color darkColor = const Color(0xFF3E2723); 

// สีข้อความรอง (สีเทาจางๆ)
Color subTextColor = const Color(0xFF9E9E9E);

// --- Text Styles (ใช้ Poppins ตามดีไซน์ในภาพ) ---

TextStyle headerTextStyle = GoogleFonts.poppins(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: primaryColor,
);

TextStyle subHeaderTextStyle = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: lightColor,
);

TextStyle labelTextStyle = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: primaryColor,
);

TextStyle bodyTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  color: subTextColor,
);

TextStyle buttonTextStyle = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: lightColor,
);