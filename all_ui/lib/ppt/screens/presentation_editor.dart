import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/presentation_component.dart';
import '../models/style/glasmorphism_style.dart';
import '../models/style/gradient_animation.dart';
import '../models/style/neumorphism_style.dart';
import '../models/style/presentation_theme.dart';
import '../states/component_provider.dart';
import '../states/history_provider.dart';
import '../states/presentation_provider.dart';
import '../widgets/canvas/slide_canvas_area.dart';
import '../widgets/properties_panel.dart';
import '../widgets/slide_panel.dart';
import '../widgets/toolbar/modern_toolbar.dart';
import '../widgets/zoom_control.dart';
import 'presenter_view.dart';

class PresentationEditor extends ConsumerWidget {
  const PresentationEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = ref.watch(presentationProvider);
    final isPresenterMode = ref.watch(presenterModeProvider);

    if (isPresenterMode) {
      return const PresenterView();
    }

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.delete) {
            final selected = ref.read(selectedComponentProvider);
            if (selected != null) {
              ref.read(presentationProvider.notifier).deleteComponent(selected);

              ref.read(selectedComponentProvider.notifier).state = null;
            }
            return KeyEventResult.handled;
          } else if (HardwareKeyboard.instance.isControlPressed) {
            if (event.logicalKey == LogicalKeyboardKey.keyZ) {
              ref.read(historyProvider.notifier).undo();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.keyY) {
              ref.read(historyProvider.notifier).redo();
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.f5) {
            ref.read(presenterModeProvider.notifier).state = true;
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          title: Row(
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
              Text(
                presentation.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      presentation.theme.primaryColor.withOpacity(0.2),
                      presentation.theme.secondaryColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: presentation.theme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Slide ${presentation.currentSlideIndex + 1}/${presentation.slides.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: presentation.theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo (Ctrl+Z)',
              onPressed:
                  ref.watch(historyProvider).canUndo
                      ? () => ref.read(historyProvider.notifier).undo()
                      : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo (Ctrl+Y)',
              onPressed:
                  ref.watch(historyProvider).canRedo
                      ? () => ref.read(historyProvider.notifier).redo()
                      : null,
            ),
            const VerticalDivider(),
            IconButton(
              icon: const Icon(Icons.palette),
              tooltip: 'Themes',
              onPressed: () => _showThemeDialog(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Visual Effects',
              onPressed: () => _showEffectsDialog(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.slideshow),
              tooltip: 'Present (F5)',
              onPressed: () {
                ref.read(presenterModeProvider.notifier).state = true;
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Row(
          children: [
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: const SlidePanel(),
            ),
            Expanded(
              child: Column(
                children: [
                  const ModernToolbar(),
                  Expanded(
                    child: Stack(
                      children: [
                        const SlideCanvasArea(),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: ZoomControls(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: const PropertiesPanel(),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text(
              'Choose Theme',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    PresentationTheme.allThemes.map((theme) {
                      return _ThemeOption(
                        theme: theme,
                        onSelect: () {
                          ref
                              .read(presentationProvider.notifier)
                              .applyTheme(theme);
                          ref
                              .read(historyProvider.notifier)
                              .addState(ref.read(presentationProvider));
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }

  void _showEffectsDialog(BuildContext context, WidgetRef ref) {
    final selected = ref.read(selectedComponentProvider);
    if (selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a component first')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text(
              'Visual Effects',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EffectTile(
                    icon: Icons.blur_on,
                    label: 'Glassmorphism',
                    effect: VisualEffect.glassmorphism,
                    onTap:
                        () => _applyEffect(
                          ref,
                          selected,
                          VisualEffect.glassmorphism,
                          context,
                        ),
                  ),
                  _EffectTile(
                    icon: Icons.layers,
                    label: 'Neumorphism',
                    effect: VisualEffect.neumorphism,
                    onTap:
                        () => _applyEffect(
                          ref,
                          selected,
                          VisualEffect.neumorphism,
                          context,
                        ),
                  ),
                  _EffectTile(
                    icon: Icons.lightbulb,
                    label: 'Glow',
                    effect: VisualEffect.glow,
                    onTap:
                        () => _applyEffect(
                          ref,
                          selected,
                          VisualEffect.glow,
                          context,
                        ),
                  ),
                  _EffectTile(
                    icon: Icons.flare,
                    label: 'Neon',
                    effect: VisualEffect.neon,
                    onTap:
                        () => _applyEffect(
                          ref,
                          selected,
                          VisualEffect.neon,
                          context,
                        ),
                  ),
                  _EffectTile(
                    icon: Icons.gradient,
                    label: 'Gradient',
                    effect: VisualEffect.gradient,
                    onTap:
                        () => _applyEffect(
                          ref,
                          selected,
                          VisualEffect.gradient,
                          context,
                        ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _applyEffect(
    WidgetRef ref,
    String componentId,
    VisualEffect effect,
    BuildContext context,
  ) {
    final presentation = ref.read(presentationProvider);
    final component = presentation
        .slides[presentation.currentSlideIndex]
        .components
        .firstWhere((c) => c.id == componentId);

    PresentationComponent updated = component.copyWith(visualEffect: effect);

    switch (effect) {
      case VisualEffect.glassmorphism:
        updated = updated.copyWith(
          glassStyle: GlassmorphismStyle(
            blur: 10,
            opacity: 0.2,
            tintColor: Colors.white,
          ),
        );
        break;
      case VisualEffect.neumorphism:
        updated = updated.copyWith(
          neumoStyle: NeumorphismStyle(
            baseColor: component.backgroundColor ?? Colors.grey[300]!,
            depth: 10,
          ),
        );
        break;
      case VisualEffect.glow:
        updated = updated.copyWith(
          hasGlow: true,
          glowColor: presentation.theme.primaryColor,
        );
        break;
      case VisualEffect.neon:
        updated = updated.copyWith(
          hasGlow: true,
          glowColor: presentation.theme.primaryColor,
        );
        break;
      case VisualEffect.gradient:
        updated = updated.copyWith(
          gradientAnim: GradientAnimation(
            colors: presentation.theme.colorPalette.take(3).toList(),
            duration: 3.0,
          ),
        );
        break;
      default:
        break;
    }

    ref
        .read(presentationProvider.notifier)
        .updateComponent(componentId, updated);
    ref.read(historyProvider.notifier).addState(ref.read(presentationProvider));
    Navigator.pop(context);
  }
}

class _ThemeOption extends StatelessWidget {
  final PresentationTheme theme;
  final VoidCallback onSelect;

  const _ThemeOption({required this.theme, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0F172A),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    theme.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children:
                    theme.colorPalette.take(5).map((color) {
                      return Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EffectTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VisualEffect effect;
  final VoidCallback onTap;

  const _EffectTile({
    required this.icon,
    required this.label,
    required this.effect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white54,
      ),
      onTap: onTap,
    );
  }
}
