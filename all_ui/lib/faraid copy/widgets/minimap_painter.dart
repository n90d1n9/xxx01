import 'package:flutter/material.dart';

import '../models/family_member.dart';
import '../models/relation_type.dart';

class MinimapPainter extends CustomPainter {
  final List<FamilyMember> members;
  final String? selectedMemberId;

  MinimapPainter(this.members, this.selectedMemberId);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint =
        Paint()
          ..color = Colors.grey[100]!
          ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    for (var member in members) {
      final x = (member.position.dx / 3000) * size.width;
      final y = (member.position.dy / 3000) * size.height;

      final paint =
          Paint()
            ..color =
                member.id == selectedMemberId
                    ? Colors.teal
                    : member.relation == RelationType.deceased
                    ? Colors.red
                    : member.faraidShare > 0
                    ? Colors.green
                    : Colors.grey
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        member.id == selectedMemberId ? 4 : 3,
        paint,
      );

      if (member.id == selectedMemberId) {
        final ringPaint =
            Paint()
              ..color = Colors.teal.withOpacity(0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
        canvas.drawCircle(Offset(x, y), 6, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(MinimapPainter oldDelegate) =>
      oldDelegate.selectedMemberId != selectedMemberId;
}
