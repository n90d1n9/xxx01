import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [const BoxShadow(color: Colors.red)],
                color: ThemeData.light(useMaterial3: true)
                    .bottomNavigationBarTheme
                    .backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavButton(Icons.home, 'Home', true),
                  _buildBottomNavButton(
                    Icons.calendar_today,
                    'Events',
                    false,
                  ),
                  _buildBottomNavButton(Icons.person, 'Profile', false),
                ],
              ),
            )));
  }

  Widget _buildBottomNavButton(IconData icon, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$label clicked')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFED9C3A) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFED9C3A) : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
