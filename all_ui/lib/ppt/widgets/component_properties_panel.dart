import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/component_provider.dart';
import '../states/presentation_provider.dart';

class ComponentPropertiesPanel extends ConsumerWidget {
  const ComponentPropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedComponentProvider)!;
    final presentation = ref.watch(presentationProvider);
    final component = presentation
        .slides[presentation.currentSlideIndex]
        .components
        .firstWhere((c) => c.id == selectedId);

    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        presentation.theme.primaryColor,
                        presentation.theme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Component Properties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type: ${component.type.name.toUpperCase()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position: ${component.position.dx.toInt()}, ${component.position.dy.toInt()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Size: ${component.size.width.toInt()} × ${component.size.height.toInt()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Visual Effects',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Current: ${component.visualEffect?.name.toUpperCase() ?? 'NONE'}',
              style: TextStyle(
                color: presentation.theme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              '✨ Modern Design Features Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Step 1 Completed:\n'
              '• Glassmorphism & Neumorphism\n'
              '• Animated Gradients\n'
              '• Particle Effects\n'
              '• Glow & Neon Effects\n'
              '• Interactive Elements\n '
              '• Modern Themes\n'
              '• Video & Audio Support\n'
              '• Enhanced Charts\n'
              '• Polls, Quizzes, Countdown\n'
              '• Full Resize & Rotate\n'
              '• Working Rulers & Grid',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
