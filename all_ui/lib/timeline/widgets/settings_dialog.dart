import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/timeline_provider.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timelineProvider);

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _SettingSection(
                    title: 'Display',
                    children: [
                      SwitchListTile(
                        title: const Text(
                          'Show Timeline',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Display mini timeline visualization',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        value: state.showTimeline,
                        onChanged:
                            (_) =>
                                ref
                                    .read(timelineProvider.notifier)
                                    .toggleTimeline(),
                        activeColor: const Color(0xFF6C63FF),
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Animated Timeline',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Auto-play timeline animation',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        value: state.animatedTimeline,
                        onChanged:
                            (_) =>
                                ref
                                    .read(timelineProvider.notifier)
                                    .toggleAnimatedTimeline(),
                        activeColor: const Color(0xFF6C63FF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingSection(
                    title: 'Zoom Level',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(state.zoomLevel * 100).toInt()}%',
                              style: const TextStyle(
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Slider(
                              value: state.zoomLevel,
                              min: 0.5,
                              max: 3.0,
                              divisions: 25,
                              activeColor: const Color(0xFF6C63FF),
                              onChanged: (value) {
                                ref
                                    .read(timelineProvider.notifier)
                                    .setZoomLevel(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingSection(
                    title: 'Notifications',
                    children: [
                      SwitchListTile(
                        title: const Text(
                          'Daily History Fact',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Receive daily historical facts',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        value: true,
                        onChanged: (value) {},
                        activeColor: const Color(0xFF6C63FF),
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Achievement Alerts',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Get notified when you unlock achievements',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        value: true,
                        onChanged: (value) {},
                        activeColor: const Color(0xFF6C63FF),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
