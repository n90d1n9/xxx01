import 'package:flutter/material.dart';

import '../schema/animation_definition.dart';
import '../screen/svg_animation_player.dart';
import '../utils/animation_exporter.dart';

class AnimationControls extends StatefulWidget {
  final GlobalKey<SvgAnimationPlayerState> playerKey;
  final SvgAnimationDefinition animation;

  const AnimationControls({
    super.key,
    required this.playerKey,
    required this.animation,
  });

  @override
  State<AnimationControls> createState() => _AnimationControlsState();
}

class _AnimationControlsState extends State<AnimationControls> {
  double _progress = 0.0;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatTime(_progress * widget.animation.duration),
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _progress,
                  onChanged: (value) {
                    setState(() => _progress = value);
                    widget.playerKey.currentState?.seekTo(value);
                  },
                ),
              ),
              Text(
                _formatTime(widget.animation.duration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {
                  widget.playerKey.currentState?.reset();
                  setState(() => _progress = 0);
                },
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 36,
                onPressed: () {
                  setState(() => _isPlaying = !_isPlaying);
                  if (_isPlaying) {
                    widget.playerKey.currentState?.play();
                  } else {
                    widget.playerKey.currentState?.pause();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () {
                  widget.playerKey.currentState?.stop();
                  setState(() {
                    _isPlaying = false;
                    _progress = 0;
                  });
                },
              ),
              const SizedBox(width: 24),
              Text('Loop: ${widget.animation.loop ? "ON" : "OFF"}'),
            ],
          ),

          const SizedBox(height: 8),

          // Export buttons
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export JSON'),
                onPressed: () => _exportAs('json'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export Lottie'),
                onPressed: () => _exportAs('lottie'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export Rive'),
                onPressed: () => _exportAs('rive'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(double seconds) {
    final ms = (seconds * 1000).round();
    return '${(ms / 1000).toStringAsFixed(2)}s';
  }

  void _exportAs(String format) {
    String content;
    String filename;

    switch (format) {
      case 'json':
        content = AnimationExporter.exportToJson(widget.animation);
        filename = '${widget.animation.id}.json';
        break;
      case 'lottie':
        content = AnimationExporter.exportToLottie(widget.animation);
        filename = '${widget.animation.id}_lottie.json';
        break;
      case 'rive':
        content = AnimationExporter.exportToRive(widget.animation);
        filename = '${widget.animation.id}_rive.json';
        break;
      default:
        return;
    }

    // Show export dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Export as $format'),
            content: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Copy to clipboard or save
                  debugPrint('Exported to $filename');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported as $filename')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
