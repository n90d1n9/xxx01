import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/family_member.dart';
import '../models/relation_type.dart';
import '../models/mahram_relationship.dart';

class FamilyTreePainter extends CustomPainter {
  final List<FamilyMember> members;
  final bool showGrid;
  final bool showMahramRelationships;
  final List<MahramRelationship> mahramRelationships;
  final String? selectedMemberId;

  FamilyTreePainter({
    required this.members,
    required this.showGrid,
    this.showMahramRelationships = false,
    this.mahramRelationships = const [],
    this.selectedMemberId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    // Draw family connection lines FIRST (behind everything)
    _drawFamilyConnections(canvas);

    // Then draw mahram relationships (if enabled)
    if (showMahramRelationships) {
      _drawMahramRelationships(canvas);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    const gridSize = 100.0;

    // Draw larger grid for better orientation
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw coordinate indicators every 500 pixels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final textStyle = TextStyle(
      color: Colors.grey.withOpacity(0.5),
      fontSize: 12,
    );

    for (double x = 0; x < size.width; x += 500) {
      for (double y = 0; y < size.height; y += 500) {
        textPainter.text = TextSpan(
          text: '(${x.toInt()}, ${y.toInt()})',
          style: textStyle,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 5, y + 5));
      }
    }
  }

  void _drawFamilyConnections(Canvas canvas) {
    final deceased = members.firstWhereOrNull(
      (m) => m.relation == RelationType.deceased,
    );
    if (deceased == null) return;

    final mainConnectionPaint =
        Paint()
          ..color = Colors.teal.withOpacity(0.6)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final dashedPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final deceasedCenter = Offset(
      deceased.position.dx + 90, // Center of member card (180/2)
      deceased.position.dy + 40, // Center of member card (80/2)
    );

    // Connect deceased to all direct family members
    for (var member in members) {
      if (member.id == deceased.id) continue;

      final memberCenter = Offset(
        member.position.dx + 90,
        member.position.dy + 40,
      );

      Paint linePaint = member.isDeceased ? dashedPaint : mainConnectionPaint;

      // Draw straight line for close relations, curved for others
      if (member.relation == RelationType.spouse ||
          member.relation == RelationType.father ||
          member.relation == RelationType.mother) {
        canvas.drawLine(deceasedCenter, memberCenter, linePaint);
      } else if (member.relation == RelationType.son ||
          member.relation == RelationType.daughter ||
          member.relation == RelationType.brother ||
          member.relation == RelationType.sister) {
        // Draw curved line for children and siblings
        final path = Path();
        path.moveTo(deceasedCenter.dx, deceasedCenter.dy);

        final midY = (deceasedCenter.dy + memberCenter.dy) / 2;
        path.cubicTo(
          deceasedCenter.dx,
          midY,
          memberCenter.dx,
          midY,
          memberCenter.dx,
          memberCenter.dy,
        );

        if (member.isDeceased) {
          _drawDashedPath(canvas, path, dashedPaint);
        } else {
          canvas.drawPath(path, linePaint);
        }
      }

      // Draw connection dots
      if (!member.isDeceased) {
        canvas.drawCircle(deceasedCenter, 4, Paint()..color = Colors.teal);
        canvas.drawCircle(memberCenter, 4, Paint()..color = Colors.teal);
      }
    }

    // Connect parents to their children (for parentId relationships)
    for (var member in members) {
      if (member.parentId != null && member.parentId!.isNotEmpty) {
        final parent = members.firstWhereOrNull((m) => m.id == member.parentId);
        if (parent != null && parent.id != deceased?.id) {
          final parentCenter = Offset(
            parent.position.dx + 90,
            parent.position.dy + 40,
          );
          final memberCenter = Offset(
            member.position.dx + 90,
            member.position.dy + 40,
          );

          final parentChildPaint =
              Paint()
                ..color = Colors.blue.withOpacity(0.4)
                ..strokeWidth = 2.0
                ..style = PaintingStyle.stroke;

          canvas.drawLine(parentCenter, memberCenter, parentChildPaint);
        }
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final nextDistance = distance + dashWidth;
        final segment = pathMetric.extractPath(distance, nextDistance);
        canvas.drawPath(segment, paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  void _drawMahramRelationships(Canvas canvas) {
    final relationshipPaint =
        Paint()
          ..color = Colors.purple.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    final highlightPaint =
        Paint()
          ..color = Colors.red.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round;

    for (final relationship in mahramRelationships) {
      final fromMember = members.firstWhereOrNull(
        (m) => m.id == relationship.fromMemberId,
      );
      final toMember = members.firstWhereOrNull(
        (m) => m.id == relationship.toMemberId,
      );

      if (fromMember != null && toMember != null) {
        final fromCenter = Offset(
          fromMember.position.dx + 90,
          fromMember.position.dy + 40,
        );
        final toCenter = Offset(
          toMember.position.dx + 90,
          toMember.position.dy + 40,
        );

        // Use different paint if either member is selected
        final paint =
            (selectedMemberId == fromMember.id ||
                    selectedMemberId == toMember.id)
                ? highlightPaint
                : relationshipPaint;

        // Draw curved line for mahram relationship
        final path = Path();
        path.moveTo(fromCenter.dx, fromCenter.dy);

        // Create a gentle curve that's different from family connections
        final controlPoint1 = Offset(
          fromCenter.dx + (toCenter.dx - fromCenter.dx) * 0.3,
          fromCenter.dy - 80,
        );
        final controlPoint2 = Offset(
          fromCenter.dx + (toCenter.dx - fromCenter.dx) * 0.7,
          toCenter.dy + 80,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          toCenter.dx,
          toCenter.dy,
        );

        canvas.drawPath(path, paint);

        // Draw relationship type indicator
        _drawRelationshipIndicator(
          canvas,
          fromCenter,
          toCenter,
          relationship.type,
        );
      }
    }
  }

  void _drawRelationshipIndicator(
    Canvas canvas,
    Offset fromPos,
    Offset toPos,
    MahramType type,
  ) {
    final midPoint = Offset(
      (fromPos.dx + toPos.dx) / 2,
      (fromPos.dy + toPos.dy) / 2 - 50,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: _getMahramTypeSymbol(type),
        style: const TextStyle(
          color: Colors.purple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  String _getMahramTypeSymbol(MahramType type) {
    return switch (type) {
      MahramType.bloodRelationship => '🩸',
      MahramType.marriageRelationship => '💍',
      MahramType.breastfeeding => '🍼',
      MahramType.specificProhibition => '🚫',
    };
  }

  @override
  bool shouldRepaint(covariant FamilyTreePainter oldDelegate) {
    return members != oldDelegate.members ||
        showGrid != oldDelegate.showGrid ||
        showMahramRelationships != oldDelegate.showMahramRelationships ||
        mahramRelationships != oldDelegate.mahramRelationships ||
        selectedMemberId != oldDelegate.selectedMemberId;
  }
}
