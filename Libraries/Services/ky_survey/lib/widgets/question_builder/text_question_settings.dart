import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextQuestionSettings extends StatelessWidget {
  final TextEditingController hintController;
  final TextEditingController maxLengthController;

  const TextQuestionSettings({
    super.key,
    required this.hintController,
    required this.maxLengthController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SettingsTitle(title: 'Text Settings'),
        const SizedBox(height: 12),
        TextField(
          controller: hintController,
          decoration: const InputDecoration(
            labelText: 'Hint Text',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: maxLengthController,
          decoration: const InputDecoration(
            labelText: 'Maximum Length',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}

class _SettingsTitle extends StatelessWidget {
  final String title;

  const _SettingsTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}
