import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/provider.dart';

class CanvasConnectingMessage extends ConsumerWidget {
  const CanvasConnectingMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectingNodeId = ref.watch(connectingNodeIdProvider);

    if (connectingNodeId == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Click on another node to connect',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  ref.read(connectingNodeIdProvider.notifier).state = null;
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
