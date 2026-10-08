// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'login_screen.dart'; // Ensure this import is correct for your project structure

// // --- Color Palette (Coffee Theme from image_0.png) ---
// Color primaryColor = const Color(0xFF6F4E37); // Dark brown (buttons, headers)
// Color secondaryColor = const Color(0xFFD7CCC8); // Latte brown (inactive dots)
// Color lightColor = const Color(0xFFFFFFFF); // Background
// Color subTextColor = const Color(0xFF9E9E9E); // Grey text

// // --- Text Styles (Poppins font as requested) ---
// TextStyle headerTextStyle = GoogleFonts.poppins(
//   fontSize: 28, // Slightly adjusted for mobile view
//   fontWeight: FontWeight.bold,
//   color: primaryColor,
// );

// TextStyle bodyTextStyle = GoogleFonts.poppins(
//   fontSize: 16,
//   color: subTextColor,
//   height: 1.5,
// );

// TextStyle buttonTextStyle = GoogleFonts.poppins(
//   fontSize: 18,
//   fontWeight: FontWeight.bold,
//   color: lightColor,
// );

// class IntroScreen extends StatefulWidget {
//   const IntroScreen({super.key});

//   @override
//   State<IntroScreen> createState() => _IntroScreenState();
// }

// class _IntroScreenState extends State<IntroScreen> {
//   final PageController _controller = PageController();
//   int _currentPage = 0;

//   // Data for 4 pages related to Car Rental
//   final List<Map<String, String>> _pages = [
//     {
//       'title': 'Find Your Perfect Drive',
//       'subtitle':
//           'Explore a wide range of vehicles tailored for your journey. From economy to luxury, we have it all.',
//     },
//     {
//       'title': 'Easy Booking Process',
//       'subtitle':
//           'Book your desired car in just a few taps. No hidden fees, just seamless travel planning.',
//     },
//     {
//       'title': 'Reliable & Secure',
//       'subtitle':
//           'Drive with confidence. All our vehicles are regularly inspected and insured for your safety.',
//     },
//     {
//       'title': '24/7 Roadside Support',
//       'subtitle':
//           'We are always here for you. Enjoy peace of mind with our round-the-clock assistance wherever you go.',
//     },
//   ];

//   Future<void> _finishOnboarding() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('seen', true);

//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const LoginScreen(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: lightColor,
//       body: Column(
//         children: [
//           // === Top Section with Image (Style from image_1.png) ===
//           // === Top Section with Image (Style from image_1.png) ===
//           Expanded(
//             flex: 3,
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: primaryColor, // สีพื้นหลัง (จะถูกรูปทับ แต่มุมโค้งยังอยู่)
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(40),
//                   bottomRight: Radius.circular(40),
//                 ),
//               ),
//               // ใช้ ClipRRect เพื่อตัดรูปให้โค้งตามขอบด้านล่าง
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(40),
//                   bottomRight: Radius.circular(40),
//                 ),
//                 child: Image.asset(
//                   'lib/images/allcar.png',
//                   // BoxFit.cover คือหัวใจสำคัญ: ขยายรูปให้เต็มพื้นที่ 
//                   // ถ้าจอเป็นแนวตั้ง มันจะตัดขอบซ้ายขวารูปออกให้อัตโนมัติ
//                   fit: BoxFit.cover, 
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//             ),
//           ),

//           // === Bottom Section with Text, Dots, and Button ===
//           Expanded(
//             flex: 2,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
//               child: Column(
//                 children: [
//                   // Page Content (Title & Subtitle)
//                   Expanded(
//                     child: PageView.builder(
//                       controller: _controller,
//                       itemCount: _pages.length,
//                       onPageChanged: (index) {
//                         setState(() {
//                           _currentPage = index;
//                         });
//                       },
//                       itemBuilder: (context, index) {
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               _pages[index]['title']!,
//                               style: headerTextStyle,
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               _pages[index]['subtitle']!,
//                               style: bodyTextStyle,
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),

//                   // Dots Indicator
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       _pages.length,
//                       (index) => AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         height: 8,
//                         width: _currentPage == index ? 24 : 8,
//                         decoration: BoxDecoration(
//                           // Active dot is primary brown, inactive is secondary light brown
//                           color: _currentPage == index
//                               ? primaryColor
//                               : secondaryColor,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Main Action Button (Full width style like image_1.png)
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_currentPage == _pages.length - 1) {
//                           _finishOnboarding();
//                         } else {
//                           _controller.nextPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor, // Coffee brown button
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 2,
//                       ),
//                       child: Text(
//                         _currentPage == _pages.length - 1
//                             ? 'Get Started'
//                             : 'Next',
//                         style: buttonTextStyle,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; 

// --- Color Palette (Coffee Theme) ---
Color primaryColor = const Color(0xFF6F4E37); 
Color secondaryColor = const Color(0xFFD7CCC8); 
Color lightColor = const Color(0xFFFFFFFF); 
Color subTextColor = const Color(0xFF9E9E9E); 

// --- Text Styles ---
TextStyle headerTextStyle = GoogleFonts.poppins(
  fontSize: 28, 
  fontWeight: FontWeight.bold,
  color: primaryColor,
);

TextStyle bodyTextStyle = GoogleFonts.poppins(
  fontSize: 16,
  color: subTextColor,
  height: 1.5,
);

TextStyle buttonTextStyle = GoogleFonts.poppins(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: lightColor,
);

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // --- แก้ไข: เพิ่ม key 'image' เพื่อระบุรูปภาพของแต่ละหน้า ---
  final List<Map<String, String>> _pages = [
    {
      'title': 'Let\'s Hit the Road!',
      'subtitle': 'Find the perfect vehicle for your next adventure. Whether it\'s a supercar or a city ride, we\'ve got you covered.',
      'image': 'lib/images/allcar.png', 
    },
    {
      'title': 'Fast. Easy. Transparent.',
      'subtitle': 'No complicated paperwork or hidden fees. Book your car in seconds and manage your deposit securely.',
      'image': 'lib/images/allcar2.png', 
    },
    {
      'title': 'Stay in the Loop',
      'subtitle': 'Never miss an update. Our smart notification system keeps you informed about your booking status in real-time.',
      'image': 'lib/images/allcar3.png', 
    },
    {
      'title': 'Ready When You Are',
      'subtitle': 'Pick up your car and go! We ensure every vehicle is in top condition for a smooth and safe ride.',
      'image': 'lib/images/allcar4.jpg', 
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size; // ไม่ได้ใช้ ลบออกได้หรือคงไว้ก็ได้

    return Scaffold(
      backgroundColor: lightColor,
      body: Column(
        children: [
          // === Top Section with Image ===
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor, 
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                // --- แก้ไข: ใช้ AnimatedSwitcher เพื่อให้รูปเปลี่ยนอย่างนุ่มนวล ---
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  // ดึงรูปภาพตาม _currentPage
                  child: Image.asset(
                    _pages[_currentPage]['image']!,
                    // Key สำคัญมาก เพื่อให้ Flutter รู้ว่าเป็น widget ใหม่และทำการ animate
                    key: ValueKey<String>(_pages[_currentPage]['image']!), 
                    fit: BoxFit.cover, 
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // === Bottom Section with Text, Dots, and Button ===
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
              child: Column(
                children: [
                  // Page Content (Title & Subtitle)
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _pages[index]['title']!,
                              style: headerTextStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _pages[index]['subtitle']!,
                              style: bodyTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryColor
                              : secondaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Main Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _finishOnboarding();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}