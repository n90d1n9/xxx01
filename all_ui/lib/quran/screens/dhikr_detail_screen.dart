import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../states/quran_provider.dart';

class DhikrDetailScreen extends ConsumerStatefulWidget {
  final DhikrItem dhikr;
  final int initialCount;
  const DhikrDetailScreen({
    super.key,
    required this.dhikr,
    required this.initialCount,
  });
  @override
  ConsumerState<DhikrDetailScreen> createState() => _DhikrDetailScreenState();
}

class _DhikrDetailScreenState extends ConsumerState<DhikrDetailScreen> {
  late int _count;
  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  Future<void> _increment() async {
    setState(() => _count++);
    await ref.read(dhikrServiceProvider).incrementDhikr(widget.dhikr.id);
    HapticFeedback.lightImpact();
    if (widget.dhikr.targetCount != null &&
        _count == widget.dhikr.targetCount) {
      HapticFeedback.mediumImpact();
      _showCompletionDialog();
    }
  }

  Future<void> _reset() async {
    setState(() => _count = 0);
    await ref.read(dhikrServiceProvider).resetDhikr(widget.dhikr.id);
    ref.invalidate(dhikrCountsProvider);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Masha Allah!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'You completed ${widget.dhikr.targetCount} times!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _reset();
                },
                child: const Text('Start Again'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        widget.dhikr.targetCount != null
            ? (_count / widget.dhikr.targetCount!).clamp(0.0, 1.0)
            : 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dhikr.transliteration),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.dhikr.arabic,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 2.0,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.dhikr.transliteration,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.dhikr.translation,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    '$_count',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (widget.dhikr.targetCount != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Target: ${widget.dhikr.targetCount}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: _increment,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 48,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TAP TO COUNT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
