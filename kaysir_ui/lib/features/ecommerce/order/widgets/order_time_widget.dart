import 'package:flutter/material.dart';

class OrderTimerWidget extends StatelessWidget {
  final DateTime orderTime;
  final Duration targetDuration;
  final void Function()? onTimeExceeded;

  const OrderTimerWidget({
    super.key,
    required this.orderTime,
    required this.targetDuration,
    this.onTimeExceeded,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now().difference(orderTime),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final elapsed = snapshot.data!;
        final remaining = targetDuration - elapsed;
        final isOverdue = remaining.isNegative;

        if (isOverdue && onTimeExceeded != null) {
          onTimeExceeded!();
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOverdue ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isOverdue
                ? '+${_formatDuration(elapsed - targetDuration)}'
                : _formatDuration(remaining),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
