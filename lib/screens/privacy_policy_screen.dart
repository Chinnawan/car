import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constant/my_constant.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Terms & Privacy Policy",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
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
              Text(
                "Last Updated: March 2026",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildSectionTitle("1. Introduction"),
              _buildParagraph(
                "Welcome to Car.Hub. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us at our Help Center."
              ),

              _buildSectionTitle("2. Information We Collect"),
              _buildParagraph(
                "We collect personal information that you voluntarily provide to us when registering at the Services, expressing an interest in obtaining information about us or our products and services, when participating in activities on the Services or otherwise contacting us."
              ),
              _buildParagraph(
                "The personal information that we collect depends on the context of your interactions with us and the Services, the choices you make and the products and features you use. The personal information we collect can include the following: Name, Phone Number, Email Address, and Payment Information."
              ),

              _buildSectionTitle("3. How We Use Your Information"),
              _buildParagraph(
                "We use personal information collected via our Services for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations."
              ),
              _buildParagraph(
                "• To facilitate account creation and logon process.\n"
                "• To manage user bookings and orders.\n"
                "• To send administrative information to you.\n"
                "• To protect our Services."
              ),

              _buildSectionTitle("4. Data Security"),
              _buildParagraph(
                "We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, please also remember that we cannot guarantee that the internet itself is 100% secure."
              ),

              _buildSectionTitle("5. Terms of Vehicle Booking"),
              _buildParagraph(
                "By booking a vehicle through Car.Hub, you agree to pay the required deposit amount. The deposit is strictly non-refundable in the event of a cancellation initiated by the customer less than 24 hours prior to the pickup time."
              ),
              
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "© 2026 Car.Hub. All rights reserved.",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: darkColor,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.6, // ทำให้บรรทัดห่างกันนิดนึง อ่านง่ายขึ้น
        ),
      ),
    );
  }
}