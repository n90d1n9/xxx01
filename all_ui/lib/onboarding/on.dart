import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trendy Onboarding',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Discover",
      description: "Explore amazing features and content tailored just for you",
      imageAsset: "assets/images/discover.png",
      backgroundColor: const Color(0xFFE0F7FA),
      illustrationColor: const Color(0xFF6C63FF),
    ),
    OnboardingItem(
      title: "Connect",
      description: "Join communities and connect with like-minded people",
      imageAsset: "assets/images/connect.png",
      backgroundColor: const Color(0xFFF3E5F5),
      illustrationColor: const Color(0xFF00BFA5),
    ),
    OnboardingItem(
      title: "Create",
      description: "Unleash your creativity with powerful tools and resources",
      imageAsset: "assets/images/create.png",
      backgroundColor: const Color(0xFFFFF8E1),
      illustrationColor: const Color(0xFFFF5252),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _onSkipPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _onSkipPressed,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = _onboardingItems[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: OnboardingPage(
                      item: item,
                      index: index,
                      isDarkMode: isDarkMode,
                    ),
                  );
                },
              ),
            ),

            // Indicators and next button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Next button
                  GestureDetector(
                    onTap: _onNextPressed,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentPage == _onboardingItems.length - 1
                            ? "Get Started"
                            : "Next",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final int index;
  final bool isDarkMode;

  const OnboardingPage({
    Key? key,
    required this.item,
    required this.index,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration placeholder (replace with actual image)
        SizedBox(
          height: size.height * 0.4,
          child: IllustrationPlaceholder(
            index: index,
            color: item.illustrationColor,
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            item.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// A simple placeholder for illustrations (replace with your actual assets)
class IllustrationPlaceholder extends StatelessWidget {
  final int index;
  final Color color;

  const IllustrationPlaceholder({
    Key? key,
    required this.index,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size(250, 250),
        painter: _IllustrationPainter(index: index, color: color),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final int index;
  final Color color;

  _IllustrationPainter({required this.index, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    switch (index) {
      case 0:
        // Discover illustration
        canvas.drawCircle(center, radius * 0.8, paint);
        final iconPaint =
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8;
        canvas.drawCircle(center, radius * 0.5, iconPaint);
        canvas.drawLine(
          Offset(center.dx + radius * 0.5, center.dy),
          Offset(center.dx + radius * 0.7, center.dy),
          iconPaint,
        );
        break;
      case 1:
        // Connect illustration
        for (int i = 0; i < 3; i++) {
          final nodeCenter = Offset(
            center.dx + radius * 0.6 * math.cos(i * 2 * math.pi / 3),
            center.dy + radius * 0.6 * math.sin(i * 2 * math.pi / 3),
          );
          canvas.drawCircle(nodeCenter, radius * 0.2, paint);
        }
        final linePaint =
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6;
        for (int i = 0; i < 3; i++) {
          final startCenter = Offset(
            center.dx + radius * 0.6 * math.cos(i * 2 * math.pi / 3),
            center.dy + radius * 0.6 * math.sin(i * 2 * math.pi / 3),
          );
          final endCenter = Offset(
            center.dx + radius * 0.6 * math.cos((i + 1) * 2 * math.pi / 3),
            center.dy + radius * 0.6 * math.sin((i + 1) * 2 * math.pi / 3),
          );
          canvas.drawLine(startCenter, endCenter, linePaint);
        }
        break;
      case 2:
        // Create illustration
        final rect = Rect.fromCenter(
          center: center,
          width: size.width * 0.8,
          height: size.height * 0.6,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(20)),
          paint,
        );
        final iconPaint =
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8;
        final pencilPath = Path();
        pencilPath.moveTo(center.dx - 30, center.dy + 30);
        pencilPath.lineTo(center.dx + 20, center.dy - 20);
        pencilPath.lineTo(center.dx + 30, center.dy - 10);
        pencilPath.lineTo(center.dx - 20, center.dy + 40);
        pencilPath.close();
        canvas.drawPath(pencilPath, iconPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(_IllustrationPainter oldDelegate) => false;
}

// Data model for onboarding items
class OnboardingItem {
  final String title;
  final String description;
  final String imageAsset;
  final Color backgroundColor;
  final Color illustrationColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.backgroundColor,
    required this.illustrationColor,
  });
}

// Placeholder for home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              "Welcome to the App!",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "You've successfully completed the onboarding process.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
