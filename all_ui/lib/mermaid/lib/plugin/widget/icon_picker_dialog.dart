import 'package:flutter/material.dart';

class IconPickerDialog extends StatelessWidget {
  final Function(IconData) onIconSelected;

  const IconPickerDialog({super.key, required this.onIconSelected});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.api,
      Icons.extension,
      Icons.code,
      Icons.http,
      Icons.storage,
      Icons.cloud,
      Icons.email,
      Icons.webhook,
      Icons.transform,
      Icons.psychology,
      Icons.functions,
      Icons.settings,
      Icons.bolt,
      Icons.star,
      Icons.work,
      Icons.person,
      Icons.shopping_cart,
      Icons.payment,
      Icons.notifications,
      Icons.chat,
    ];

    return Dialog(
      backgroundColor: const Color(0xFF2D2D2D),
      child: Container(
        width: 400,
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Select Icon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 5,
                children: icons
                    .map(
                      (icon) => IconButton(
                        icon: Icon(icon, color: Colors.white),
                        onPressed: () => onIconSelected(icon),
                        iconSize: 32,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
