import 'package:flutter/material.dart';

import '../../../features/table/bottom_nav_bar.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  bool isShowChatbot = false;

  bool isShowChatButton = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar

                  // Carousel
                  //const NewsInfoCarousel(),
                ],
              ),
            ),
            const BottomNavBar(),
          ],
        ),
      ),
    );
  }

  void openChatbot() {
    setState(() {
      isShowChatbot = isShowChatbot ? false : true;

      isShowChatButton = false;
    });
  }
}
