import 'package:flutter/material.dart';

class PublicFooter extends StatelessWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Us',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Our Story'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Team'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Careers'),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resources',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Blog'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Documentation'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Help Center'),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Support'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Sales'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Partner'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('© 2024 Your Company. All rights reserved.'),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Privacy Policy'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Terms of Service'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
