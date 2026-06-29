import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/presentation.dart';
import '../models/style/gradient_animation.dart';
import '../models/style/particle_effect.dart';
import '../states/history_provider.dart';
import '../states/presentation_provider.dart';

class SlidePropertiesPanel extends ConsumerWidget {
  const SlidePropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = ref.watch(presentationProvider);
    final currentSlide = presentation.slides[presentation.currentSlideIndex];

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
                  child: const Icon(
                    Icons.slideshow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Slide Properties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Background Effects',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () => _addBackgroundGradient(ref, presentation),
              icon: const Icon(Icons.gradient),
              label: const Text('Animated Gradient'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: () => _addBackgroundParticles(ref, presentation),
              icon: const Icon(Icons.blur_on),
              label: const Text('Particle Effect'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF334155),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Slide Info',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Components: ${currentSlide.components.length}',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Slide ${presentation.currentSlideIndex + 1} of ${presentation.slides.length}',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _addBackgroundGradient(WidgetRef ref, Presentation presentation) {
    final gradient = GradientAnimation(
      colors: presentation.theme.colorPalette.take(3).toList(),
      duration: 4.0,
    );
    ref
        .read(presentationProvider.notifier)
        .setSlideBackgroundGradient(gradient);
    ref.read(historyProvider.notifier).addState(ref.read(presentationProvider));
  }

  void _addBackgroundParticles(WidgetRef ref, Presentation presentation) {
    final particles = ParticleEffect(
      particleCount: 50,
      color: presentation.theme.primaryColor.withOpacity(0.5),
      speed: 0.5,
      size: 3.0,
    );
    ref
        .read(presentationProvider.notifier)
        .setSlideBackgroundParticles(particles);
    ref.read(historyProvider.notifier).addState(ref.read(presentationProvider));
  }
}
