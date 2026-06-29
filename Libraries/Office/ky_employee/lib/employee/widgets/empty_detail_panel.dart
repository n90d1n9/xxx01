import 'package:flutter/material.dart';

class EmptyDetailPanel extends StatelessWidget {
  const EmptyDetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
      child: Card(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search, size: 64, color: Color(0xFFD1D5DB)),
              SizedBox(height: 16),
              Text(
                'Select an employee to view details',
                style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
