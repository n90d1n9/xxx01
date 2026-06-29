import 'package:flutter/material.dart';

import '../form_designer/model/field_config.dart';

class AnimationEditor extends StatefulWidget {
  final FieldConfig field;
  final Function(AnimationConfig) onSave;

  const AnimationEditor({super.key, required this.field, required this.onSave});

  @override
  State<AnimationEditor> createState() => _AnimationEditorState();
}

class _AnimationEditorState extends State<AnimationEditor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  AnimationType selectedType = AnimationType.fadeIn;
  double duration = 300;
  Curve selectedCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration.toInt()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.animation, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Animation Editor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Preview
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Center(child: _buildAnimatedPreview()),
          ),
          const SizedBox(height: 24),

          // Animation type selector
          const Text(
            'Animation Type:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AnimationType.values.map((type) {
              return ChoiceChip(
                label: Text(type.toString().split('.').last),
                selected: selectedType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => selectedType = type);
                    _playPreview();
                  }
                },
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                  color: selectedType == type ? Colors.white : Colors.white70,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Duration slider
          const Text(
            'Duration:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: duration,
                  min: 100,
                  max: 2000,
                  divisions: 19,
                  label: '${duration.toInt()}ms',
                  onChanged: (value) {
                    setState(() {
                      duration = value;
                      _controller.duration = Duration(
                        milliseconds: value.toInt(),
                      );
                    });
                  },
                ),
              ),
              Text(
                '${duration.toInt()}ms',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Curve selector
          const Text(
            'Easing:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CurveChip(
                label: 'Linear',
                curve: Curves.linear,
                selected: selectedCurve == Curves.linear,
                onSelected: (curve) => setState(() => selectedCurve = curve),
              ),
              _CurveChip(
                label: 'Ease In',
                curve: Curves.easeIn,
                selected: selectedCurve == Curves.easeIn,
                onSelected: (curve) => setState(() => selectedCurve = curve),
              ),
              _CurveChip(
                label: 'Ease Out',
                curve: Curves.easeOut,
                selected: selectedCurve == Curves.easeOut,
                onSelected: (curve) => setState(() => selectedCurve = curve),
              ),
              _CurveChip(
                label: 'Ease In Out',
                curve: Curves.easeInOut,
                selected: selectedCurve == Curves.easeInOut,
                onSelected: (curve) => setState(() => selectedCurve = curve),
              ),
              _CurveChip(
                label: 'Bounce',
                curve: Curves.bounceOut,
                selected: selectedCurve == Curves.bounceOut,
                onSelected: (curve) => setState(() => selectedCurve = curve),
              ),
              _CurveChip(
                label: 'Elastic',
                curve: Curves.elasticOut,
                selected: selectedCurve == Curves.elasticOut,
                onSelected: (curve) => setState(() => selectedCurve = curve),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Preview'),
                onPressed: _playPreview,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Reset'),
                onPressed: () => _controller.reset(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Apply'),
                onPressed: () {
                  widget.onSave(
                    AnimationConfig(
                      type: selectedType,
                      duration: duration.toInt(),
                      curve: selectedCurve,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPreview() {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: selectedCurve,
    );

    switch (selectedType) {
      case AnimationType.fadeIn:
        return FadeTransition(opacity: animation, child: _previewWidget());
      case AnimationType.slideInLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: _previewWidget(),
        );
      case AnimationType.slideInRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: _previewWidget(),
        );
      case AnimationType.slideInUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: _previewWidget(),
        );
      case AnimationType.slideInDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: _previewWidget(),
        );
      case AnimationType.scaleIn:
        return ScaleTransition(scale: animation, child: _previewWidget());
      case AnimationType.rotateIn:
        return RotationTransition(turns: animation, child: _previewWidget());
    }
  }

  Widget _previewWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.field.label ?? 'Preview Field',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _playPreview() {
    _controller.reset();
    _controller.forward();
  }
}

enum AnimationType {
  fadeIn,
  slideInLeft,
  slideInRight,
  slideInUp,
  slideInDown,
  scaleIn,
  rotateIn,
}

class AnimationConfig {
  final AnimationType type;
  final int duration;
  final Curve curve;

  const AnimationConfig({
    required this.type,
    required this.duration,
    required this.curve,
  });
}

class _CurveChip extends StatelessWidget {
  final String label;
  final Curve curve;
  final bool selected;
  final Function(Curve) onSelected;

  const _CurveChip({
    required this.label,
    required this.curve,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (sel) {
        if (sel) onSelected(curve);
      },
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontSize: 12,
      ),
    );
  }
}
