import 'package:flutter/material.dart';

import '../models/family.dart';
import '../models/gender.dart';

class MemberNodeWidget extends StatelessWidget {
  final FamilyMember member;
  final bool isSelected;
  final bool hasInheritance;
  final VoidCallback onTap;

  const MemberNodeWidget({
    super.key,
    required this.member,
    required this.isSelected,
    required this.hasInheritance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              member.isDeceased
                  ? Colors.grey.shade300
                  : (member.gender == Gender.male
                      ? Colors.blue.shade100
                      : Colors.pink.shade100),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.black87,
            width: isSelected ? 3 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (hasInheritance)
              BoxShadow(
                color: Colors.green.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              member.gender == Gender.male ? Icons.male : Icons.female,
              color:
                  member.gender == Gender.male
                      ? Colors.blue.shade700
                      : Colors.pink.shade700,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              member.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration:
                    member.isDeceased ? TextDecoration.lineThrough : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (member.age != null)
              Text(
                '${member.age} years',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            if (member.isDeceased)
              Icon(Icons.close, size: 16, color: Colors.grey.shade700),
            if (hasInheritance)
              Icon(
                Icons.monetization_on,
                size: 16,
                color: Colors.green.shade700,
              ),
          ],
        ),
      ),
    );
  }
}
