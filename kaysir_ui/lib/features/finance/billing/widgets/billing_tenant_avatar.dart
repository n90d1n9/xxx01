import 'package:flutter/material.dart';

class BillingTenantAvatar extends StatelessWidget {
  final String name;
  final String logoUrl;
  final double radius;

  const BillingTenantAvatar({
    super.key,
    required this.name,
    required this.logoUrl,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedLogoUrl = logoUrl.trim();
    final hasLogo = normalizedLogoUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE0E7FF),
      backgroundImage: hasLogo ? NetworkImage(normalizedLogoUrl) : null,
      onBackgroundImageError: hasLogo ? (_, _) {} : null,
      child:
          hasLogo
              ? null
              : Text(
                _initials(name),
                style: TextStyle(
                  color: const Color(0xFF4F46E5),
                  fontSize: radius * 0.62,
                  fontWeight: FontWeight.w700,
                ),
              ),
    );
  }

  String _initials(String value) {
    final words =
        value
            .trim()
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .toList();
    if (words.isEmpty) return '?';
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }
}
