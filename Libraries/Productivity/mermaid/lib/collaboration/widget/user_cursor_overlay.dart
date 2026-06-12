// User Cursor Overlay Widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../collaboration_user.dart';
import '../state/collaboration_provider.dart';
import '../user_role.dart';

class UserCursorsOverlay extends ConsumerWidget {
  const UserCursorsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collabState = ref.watch(collaborationProvider);
    final users = collabState.activeUsers;
    final cursors = collabState.userCursors;

    return IgnorePointer(
      child: Stack(
        children: cursors.entries.map((entry) {
          final userId = entry.key;
          final cursor = entry.value;
          final user = users.firstWhere(
            (u) => u.id == userId,
            orElse: () => CollaborationUser(
              id: userId,
              name: 'Unknown',
              email: '',
              color: Colors.grey,
              lastActive: DateTime.now(),
            ),
          );

          return Positioned(
            left: cursor.position.dx,
            top: cursor.position.dy,
            child: _CursorWidget(user: user, cursor: cursor),
          );
        }).toList(),
      ),
    );
  }
}

class _CursorWidget extends StatelessWidget {
  final CollaborationUser user;
  final UserCursor cursor;

  const _CursorWidget({required this.user, required this.cursor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPaint(
          size: const Size(20, 20),
          painter: CursorPainter(color: user.color),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user.color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class CursorPainter extends CustomPainter {
  final Color color;

  CursorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
