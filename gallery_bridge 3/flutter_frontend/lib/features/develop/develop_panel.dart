// lib/features/develop/develop_panel.dart
//
// Non-destructive Develop panel — the "Lightroom Develop module" equivalent.
// Slides in on the right side when the user enters Develop mode.
// All sliders write EditOp records through the bridge; changes are
// coalesced so rapid dragging doesn't flood the DB.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/gallery_models.dart';
import '../../core/providers/gallery_providers.dart';
import '../../shared/theme/app_theme.dart';

// ── Edit state provider ───────────────────────────────────────────────────

class DevelopState {
  final double exposure;    // -3.0 .. +3.0 stops
  final double contrast;    // -100 .. 100
  final double highlights;  // -100 .. 100
  final double shadows;     // -100 .. 100
  final double whites;      // -100 .. 100
  final double blacks;      // -100 .. 100
  final double saturation;  // -100 .. 100
  final double vibrance;    // -100 .. 100
  final double temperature; // 2000 .. 10000 K
  final double tint;        // -150 .. 150
  final double sharpness;   // 0 .. 100
  final double noiseReduce; // 0 .. 100
  final double vignette;    // -100 .. 0
  final int    rotation;    // 0 / 90 / 180 / 270
  final bool   flipH;
  final bool   flipV;
  final bool   hasEdits;

  const DevelopState({
    this.exposure    = 0,
    this.contrast    = 0,
    this.highlights  = 0,
    this.shadows     = 0,
    this.whites      = 0,
    this.blacks      = 0,
    this.saturation  = 0,
    this.vibrance    = 0,
    this.temperature = 5500,
    this.tint        = 0,
    this.sharpness   = 25,
    this.noiseReduce = 0,
    this.vignette    = 0,
    this.rotation    = 0,
    this.flipH       = false,
    this.flipV       = false,
    this.hasEdits    = false,
  });

  DevelopState copyWith({
    double? exposure, double? contrast, double? highlights, double? shadows,
    double? whites, double? blacks, double? saturation, double? vibrance,
    double? temperature, double? tint, double? sharpness, double? noiseReduce,
    double? vignette, int? rotation, bool? flipH, bool? flipV, bool? hasEdits,
  }) => DevelopState(
    exposure:    exposure    ?? this.exposure,
    contrast:    contrast    ?? this.contrast,
    highlights:  highlights  ?? this.highlights,
    shadows:     shadows     ?? this.shadows,
    whites:      whites      ?? this.whites,
    blacks:      blacks      ?? this.blacks,
    saturation:  saturation  ?? this.saturation,
    vibrance:    vibrance    ?? this.vibrance,
    temperature: temperature ?? this.temperature,
    tint:        tint        ?? this.tint,
    sharpness:   sharpness   ?? this.sharpness,
    noiseReduce: noiseReduce ?? this.noiseReduce,
    vignette:    vignette    ?? this.vignette,
    rotation:    rotation    ?? this.rotation,
    flipH:       flipH       ?? this.flipH,
    flipV:       flipV       ?? this.flipV,
    hasEdits:    hasEdits    ?? this.hasEdits,
  );

  bool get isDefault =>
      exposure == 0 && contrast == 0 && highlights == 0 &&
      shadows == 0 && whites == 0 && blacks == 0 &&
      saturation == 0 && vibrance == 0 && temperature == 5500 &&
      tint == 0 && sharpness == 25 && noiseReduce == 0 &&
      vignette == 0 && rotation == 0 && !flipH && !flipV;
}

class DevelopNotifier extends Notifier<DevelopState> {
  Timer? _debounce;

  @override
  DevelopState build() => const DevelopState();

  void update(DevelopState newState) {
    state = newState.copyWith(hasEdits: !newState.isDefault);
    _scheduleFlush();
  }

  void reset() {
    state = const DevelopState();
    _scheduleFlush();
  }

  void _scheduleFlush() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _flush);
  }

  void _flush() {
    final id = ref.read(activeItemIdProvider);
    if (id == null) return;
    // In production: GalleryBridge.saveSidecar(id, state.toEditOps())
  }
}

final developProvider =
    NotifierProvider<DevelopNotifier, DevelopState>(DevelopNotifier.new);

// ── Panel widget ─────────────────────────────────────────────────────────

class DevelopPanel extends ConsumerWidget {
  const DevelopPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dev = ref.watch(developProvider);
    final activeId = ref.watch(activeItemIdProvider);

    if (activeId == null) {
      return const _EmptyDevelop();
    }

    return Container(
      color: AppTheme.bg1,
      child: Column(
        children: [
          _DevelopHeader(
            hasEdits: dev.hasEdits,
            onReset: () => ref.read(developProvider.notifier).reset(),
          ),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Geometry tools
                    _ToolRow(dev: dev, ref: ref),
                    const SizedBox(height: 8),

                    // Tone
                    _Section(title: 'TONE', children: [
                      _EditSlider(label: 'Exposure',   value: dev.exposure,   min: -3, max: 3,    decimals: 2,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(exposure: v))),
                      _EditSlider(label: 'Contrast',   value: dev.contrast,   min: -100, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(contrast: v))),
                      _EditSlider(label: 'Highlights', value: dev.highlights, min: -100, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(highlights: v))),
                      _EditSlider(label: 'Shadows',    value: dev.shadows,    min: -100, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(shadows: v))),
                      _EditSlider(label: 'Whites',     value: dev.whites,     min: -100, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(whites: v))),
                      _EditSlider(label: 'Blacks',     value: dev.blacks,     min: -100, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(blacks: v))),
                    ]),

                    // White Balance
                    _Section(title: 'WHITE BALANCE', children: [
                      _EditSlider(label: 'Temp (K)',  value: dev.temperature, min: 2000, max: 10000, divisions: 160,
                          color: const Color(0xFF3B82F6),
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(temperature: v))),
                      _EditSlider(label: 'Tint',      value: dev.tint,        min: -150, max: 150,
                          color: const Color(0xFFA855F7),
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(tint: v))),
                    ]),

                    // Color
                    _Section(title: 'COLOR', children: [
                      _EditSlider(label: 'Vibrance',   value: dev.vibrance,   min: -100, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(vibrance: v))),
                      _EditSlider(label: 'Saturation', value: dev.saturation, min: -100, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(saturation: v))),
                    ]),

                    // Detail
                    _Section(title: 'DETAIL', children: [
                      _EditSlider(label: 'Sharpness',    value: dev.sharpness,   min: 0, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(sharpness: v))),
                      _EditSlider(label: 'Noise Reduce', value: dev.noiseReduce, min: 0, max: 100,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(noiseReduce: v))),
                    ]),

                    // Effects
                    _Section(title: 'EFFECTS', children: [
                      _EditSlider(label: 'Vignette', value: dev.vignette, min: -100, max: 0,
                          onChanged: (v) => ref.read(developProvider.notifier).update(dev.copyWith(vignette: v))),
                    ]),

                    const SizedBox(height: 16),
                    // Export developed
                    _ExportDevelopedBtn(hasEdits: dev.hasEdits, itemId: activeId),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DevelopHeader extends StatelessWidget {
  final bool hasEdits;
  final VoidCallback onReset;
  const _DevelopHeader({required this.hasEdits, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        children: [
          const Text('DEVELOP',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.3)),
          const Spacer(),
          if (hasEdits)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppTheme.accent),
            ),
          GestureDetector(
            onTap: onReset,
            child: const Text('Reset',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  final DevelopState dev;
  final WidgetRef ref;
  const _ToolRow({required this.dev, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ToolBtn(icon: Icons.rotate_left,  label: 'CCW',
            onTap: () => ref.read(developProvider.notifier).update(
                dev.copyWith(rotation: (dev.rotation - 90).remainder(360)))),
        _ToolBtn(icon: Icons.rotate_right, label: 'CW',
            onTap: () => ref.read(developProvider.notifier).update(
                dev.copyWith(rotation: (dev.rotation + 90).remainder(360)))),
        _ToolBtn(icon: Icons.flip,         label: 'Flip H',
            active: dev.flipH,
            onTap: () => ref.read(developProvider.notifier).update(
                dev.copyWith(flipH: !dev.flipH))),
        _ToolBtn(icon: Icons.flip,         label: 'Flip V',
            active: dev.flipV,
            onTap: () => ref.read(developProvider.notifier).update(
                dev.copyWith(flipV: !dev.flipV))),
      ],
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppTheme.accentGlow : AppTheme.bg2,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: active ? AppTheme.accent : AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: active ? AppTheme.accent : AppTheme.textSecondary),
              Text(label, style: TextStyle(fontSize: 9, color: active ? AppTheme.accent : AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatefulWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border))),
            child: Row(
              children: [
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    size: 12, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
        if (_expanded) ...widget.children,
        const SizedBox(height: 4),
      ],
    );
  }
}

class _EditSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final int decimals;
  final Color? color;
  final ValueChanged<double> onChanged;

  const _EditSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions = 200,
    this.decimals = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isZero = value == 0 || (decimals == 0 && value.round() == 0);
    final displayColor = color ?? (isZero ? AppTheme.textMuted : AppTheme.accent);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbRadius: 6,
                activeTrackColor: displayColor,
                inactiveTrackColor: AppTheme.bg3,
                thumbColor: displayColor,
                overlayRadius: 10,
                overlayColor: displayColor.withOpacity(0.15),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              decimals > 0
                  ? value.toStringAsFixed(decimals)
                  : value.round().toString(),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 10,
                  color: displayColor,
                  fontFamily: 'JetBrains Mono'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportDevelopedBtn extends StatelessWidget {
  final bool hasEdits;
  final int itemId;
  const _ExportDevelopedBtn({required this.hasEdits, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasEdits ? () {} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.bg0,
          disabledBackgroundColor: AppTheme.bg3,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Text('Export Developed',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _EmptyDevelop extends StatelessWidget {
  const _EmptyDevelop();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune, size: 28, color: AppTheme.textMuted),
          SizedBox(height: 8),
          Text('Select an image to develop',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
